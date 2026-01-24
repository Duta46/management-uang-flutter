<?php

namespace App\Services;

/**
 * Financial Chatbot Service Interface using Qwen AI via OpenRouter
 * Defines the contract for AI-powered financial chatbot services
 */
interface FinancialChatbotServiceInterface
{
    /**
     * Process user's financial question and return answer using Qwen AI via OpenRouter
     */
    public function processQuestion(?int $userId, string $question): array;
}