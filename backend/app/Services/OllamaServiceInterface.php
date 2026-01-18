<?php

namespace App\Services;

/**
 * Ollama Service Interface
 * Defines the contract for local Ollama AI services
 */
interface OllamaServiceInterface
{
    /**
     * Generate response using local Ollama model
     */
    public function generateResponse(array $data): array;

    /**
     * Generate financial insights using local Ollama model
     */
    public function generateFinancialInsights(array $financialData): array;

    /**
     * Generate budget recommendations using local Ollama model
     */
    public function generateBudgetRecommendations(array $financialData): array;

    /**
     * Generate spending pattern analysis using local Ollama model
     */
    public function generateSpendingPatternAnalysis(array $financialData): array;

    /**
     * Test the connection to Ollama API
     */
    public function testConnection(): array;
}