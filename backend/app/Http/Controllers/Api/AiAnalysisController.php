<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AiAnalysisService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;

/**
 * AI Analysis Controller using Qwen AI via OpenRouter
 * Handles API requests for AI-powered financial analysis
 */
class AiAnalysisController extends Controller
{
    private AiAnalysisService $aiAnalysisService;

    public function __construct(AiAnalysisService $aiAnalysisService)
    {
        $this->aiAnalysisService = $aiAnalysisService;
    }

    /**
     * Get AI-generated financial insights for the authenticated user using Qwen AI via OpenRouter
     */
    public function getInsights(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $analysisType = $request->get('type', 'general'); // Default to general analysis
        $dateRange = [
            'start_date' => $request->get('start_date', now()->subMonth()->format('Y-m-d')),
            'end_date' => $request->get('end_date', now()->format('Y-m-d')),
        ];

        $insights = $this->aiAnalysisService->getFinancialInsights($userId, $analysisType, $dateRange);

        return response()->json([
            'success' => true,
            'data' => $insights,
            'message' => 'AI financial insights retrieved successfully'
        ]);
    }

    /**
     * Get spending pattern analysis using Qwen AI via OpenRouter
     */
    public function getSpendingPattern(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $dateRange = [
            'start_date' => $request->get('start_date', now()->subMonth()->format('Y-m-d')),
            'end_date' => $request->get('end_date', now()->format('Y-m-d')),
        ];

        $spendingPattern = $this->aiAnalysisService->getSpendingPatternAnalysis($userId, $dateRange);

        return response()->json([
            'success' => true,
            'data' => $spendingPattern,
            'message' => 'Spending pattern analysis retrieved successfully'
        ]);
    }

    /**
     * Get budget recommendations using Qwen AI via OpenRouter
     */
    public function getBudgetRecommendations(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $dateRange = [
            'start_date' => $request->get('start_date', now()->subMonth()->format('Y-m-d')),
            'end_date' => $request->get('end_date', now()->format('Y-m-d')),
        ];

        $recommendations = $this->aiAnalysisService->getBudgetRecommendations($userId, $dateRange);

        return response()->json([
            'success' => true,
            'data' => $recommendations,
            'message' => 'Budget recommendations retrieved successfully'
        ]);
    }

    /**
     * Get savings insights using Qwen AI via OpenRouter
     */
    public function getSavingsInsights(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $dateRange = [
            'start_date' => $request->get('start_date', now()->subMonth()->format('Y-m-d')),
            'end_date' => $request->get('end_date', now()->format('Y-m-d')),
        ];

        $savingsInsights = $this->aiAnalysisService->getSavingsInsights($userId, $dateRange);

        return response()->json([
            'success' => true,
            'data' => $savingsInsights,
            'message' => 'Savings insights retrieved successfully'
        ]);
    }

    /**
     * Generate a new AI analysis using Qwen AI via OpenRouter
     */
    public function generateAnalysis(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $analysisType = $request->get('type', 'general');
        $dateRange = [
            'start_date' => $request->get('start_date', now()->subMonth()->format('Y-m-d')),
            'end_date' => $request->get('end_date', now()->format('Y-m-d')),
        ];

        $analysis = $this->aiAnalysisService->generateAnalysis($userId, $analysisType, $dateRange);

        return response()->json([
            'success' => true,
            'data' => $analysis,
            'message' => 'AI analysis generated successfully'
        ]);
    }

    /**
     * Test OpenRouter API connection with Qwen model
     */
    public function testConnection(): JsonResponse
    {
        $result = $this->aiAnalysisService->testGeminiConnection();

        return response()->json([
            'success' => $result['success'],
            'message' => $result['message'],
            'data' => $result['response'] ?? null
        ]);
    }
}
