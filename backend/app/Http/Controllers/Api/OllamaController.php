<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\OllamaServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Ollama Controller for local AI model integration
 * Handles API requests for the local Ollama AI model
 */
class OllamaController extends Controller
{
    private OllamaServiceInterface $ollamaService;

    public function __construct(OllamaServiceInterface $ollamaService)
    {
        $this->ollamaService = $ollamaService;
    }

    /**
     * Generate response using local Ollama model
     */
    public function generate(Request $request): JsonResponse
    {
        $request->validate([
            'prompt' => 'required|string|max:5000',
            'system_prompt' => 'nullable|string|max:2000',
            'options' => 'nullable|array'
        ]);

        $data = [
            'prompt' => $request->input('prompt'),
            'system_prompt' => $request->input('system_prompt', 'You are a helpful assistant.'),
            'options' => $request->input('options', [
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ])
        ];

        $response = $this->ollamaService->generateResponse($data);

        return response()->json([
            'success' => $response['success'],
            'data' => $response['data'] ?? null,
            'error' => $response['error'] ?? null,
            'message' => $response['success'] ? 'Response generated successfully' : 'Failed to generate response'
        ]);
    }

    /**
     * Test Ollama connection
     */
    public function testConnection(): JsonResponse
    {
        $result = $this->ollamaService->testConnection();

        return response()->json([
            'success' => $result['success'],
            'message' => $result['success'] ? 'Ollama connection successful' : 'Ollama connection failed',
            'data' => $result['data'] ?? null,
            'error' => $result['error'] ?? null
        ]);
    }

    /**
     * Generate financial insights using local Ollama model
     */
    public function generateFinancialInsights(Request $request): JsonResponse
    {
        $request->validate([
            'total_income' => 'nullable|numeric',
            'total_expense' => 'nullable|numeric',
            'categories' => 'nullable|array',
            'transactions' => 'nullable|array',
            'prompt' => 'nullable|string|max:5000'
        ]);

        $financialData = $request->all();

        $response = $this->ollamaService->generateFinancialInsights($financialData);

        return response()->json([
            'success' => $response['success'],
            'data' => $response['data'] ?? null,
            'error' => $response['error'] ?? null,
            'message' => $response['success'] ? 'Financial insights generated successfully' : 'Failed to generate financial insights'
        ]);
    }

    /**
     * Generate budget recommendations using local Ollama model
     */
    public function generateBudgetRecommendations(Request $request): JsonResponse
    {
        $request->validate([
            'total_income' => 'nullable|numeric',
            'categories' => 'nullable|array',
            'prompt' => 'nullable|string|max:5000'
        ]);

        $financialData = $request->all();

        $response = $this->ollamaService->generateBudgetRecommendations($financialData);

        return response()->json([
            'success' => $response['success'],
            'data' => $response['data'] ?? null,
            'error' => $response['error'] ?? null,
            'message' => $response['success'] ? 'Budget recommendations generated successfully' : 'Failed to generate budget recommendations'
        ]);
    }

    /**
     * Generate spending pattern analysis using local Ollama model
     */
    public function generateSpendingPatternAnalysis(Request $request): JsonResponse
    {
        $request->validate([
            'transactions' => 'nullable|array',
            'categories' => 'nullable|array',
            'daily_spending' => 'nullable|array',
            'prompt' => 'nullable|string|max:5000'
        ]);

        $financialData = $request->all();

        $response = $this->ollamaService->generateSpendingPatternAnalysis($financialData);

        return response()->json([
            'success' => $response['success'],
            'data' => $response['data'] ?? null,
            'error' => $response['error'] ?? null,
            'message' => $response['success'] ? 'Spending pattern analysis generated successfully' : 'Failed to generate spending pattern analysis'
        ]);
    }
}