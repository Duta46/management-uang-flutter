<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\FinancialChatbotServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Financial Chatbot Controller using Qwen AI via OpenRouter
 * Handles API requests for the financial chatbot using AI
 */
class FinancialChatbotController extends Controller
{
    private FinancialChatbotServiceInterface $chatbotService;

    public function __construct(FinancialChatbotServiceInterface $chatbotService)
    {
        $this->chatbotService = $chatbotService;
    }

    /**
     * Process a financial question from the user using Qwen AI via OpenRouter
     */
    public function askQuestion(Request $request): JsonResponse
    {
        $request->validate([
            'question' => 'required|string|max:500',
        ]);

        $userId = auth()->id();
        $question = $request->input('question');

        try {
            $response = $this->chatbotService->processQuestion($userId, $question);

            return response()->json([
                'success' => true,
                'data' => [
                    'answer' => $response['answer'],
                    'intent' => $response['intent'] ?? null,
                ],
                'message' => 'Pertanyaan berhasil diproses'
            ]);
        } catch (\Exception $e) {
            \Illuminate\Support\Facades\Log::error('Chatbot error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'data' => null,
                'message' => 'Terjadi kesalahan server. Silakan coba lagi nanti.'
            ], 500);
        }
    }

    /**
     * Get conversation history for the user with Qwen AI via OpenRouter
     */
    public function getHistory(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $limit = $request->get('limit', 10);
        $page = $request->get('page', 1);

        $conversations = \App\Models\ChatbotConversation::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->paginate($limit);

        return response()->json([
            'success' => true,
            'data' => $conversations->items(),
            'pagination' => [
                'current_page' => $conversations->currentPage(),
                'last_page' => $conversations->lastPage(),
                'per_page' => $conversations->perPage(),
                'total' => $conversations->total(),
            ],
            'message' => 'Riwayat percakapan berhasil diambil'
        ]);
    }
}