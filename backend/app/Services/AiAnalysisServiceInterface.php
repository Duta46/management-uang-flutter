<?php

namespace App\Services;

/**
 * AI Analysis Service Interface using Qwen AI via OpenRouter
 * Defines the contract for AI-powered financial analysis services
 */
interface AiAnalysisServiceInterface
{
    /**
     * Get financial insights for a user using Qwen AI via OpenRouter
     */
    public function getFinancialInsights(int $userId, string $analysisType, array $dateRange): array;

    /**
     * Get spending pattern analysis using Qwen AI via OpenRouter
     */
    public function getSpendingPatternAnalysis(int $userId, array $dateRange): array;

    /**
     * Get budget recommendations using Qwen AI via OpenRouter
     */
    public function getBudgetRecommendations(int $userId, array $dateRange): array;

    /**
     * Get savings insights using Qwen AI via OpenRouter
     */
    public function getSavingsInsights(int $userId, array $dateRange): array;

    /**
     * Generate a new AI analysis using Qwen AI via OpenRouter
     */
    public function generateAnalysis(int $userId, string $analysisType, array $dateRange): array;

    /**
     * Test OpenRouter API connection with Qwen model
     */
    public function testGeminiConnection(): array;
}
