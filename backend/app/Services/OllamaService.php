<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * Ollama Service for local AI model integration
 * This class handles communication with the locally running Ollama service
 */
class OllamaService implements OllamaServiceInterface
{
    private string $apiUrl;
    private string $model;

    public function __construct()
    {
        $this->apiUrl = env('OLLAMA_API_URL', 'http://localhost:11434/api');
        $this->model = env('OLLAMA_MODEL', 'qwen2.5:3b');
    }

    /**
     * Generate response using local Ollama model
     */
    public function generateResponse(array $data): array
    {
        $prompt = $data['prompt'] ?? '';
        $systemPrompt = $data['system_prompt'] ?? 'You are a helpful assistant.';
        $options = $data['options'] ?? [
            'temperature' => 0.7,
            'max_tokens' => 2048,
        ];

        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
            ])->timeout(60) // Set timeout to 60 seconds for local processing
            ->post($this->apiUrl . '/generate', [
                'model' => $this->model,
                'prompt' => $prompt,
                'system' => $systemPrompt,
                'options' => $options,
                'stream' => false
            ]);

            if ($response->successful()) {
                $data = $response->json();
                
                return [
                    'success' => true,
                    'data' => [
                        'response' => $data['response'] ?? '',
                        'model' => $data['model'] ?? $this->model,
                        'total_duration' => $data['total_duration'] ?? null,
                        'load_duration' => $data['load_duration'] ?? null,
                    ],
                    'raw_response' => $data
                ];
            } else {
                Log::error('Ollama API Error: ' . $response->body());

                return [
                    'success' => false,
                    'error' => 'API Error: ' . $response->body(),
                    'data' => null
                ];
            }
        } catch (\Exception $e) {
            Log::error('Ollama API Exception: ' . $e->getMessage());

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'data' => null
            ];
        }
    }

    /**
     * Generate financial insights using local Ollama model
     */
    public function generateFinancialInsights(array $financialData): array
    {
        // Check if financialData contains a custom prompt
        if (isset($financialData['prompt'])) {
            $prompt = $financialData['prompt'];
        } else {
            $prompt = $this->createFinancialAnalysisPrompt($financialData);
        }

        $systemPrompt = 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.';

        return $this->generateResponse([
            'prompt' => $prompt,
            'system_prompt' => $systemPrompt,
            'options' => [
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]
        ]);
    }

    /**
     * Generate budget recommendations using local Ollama model
     */
    public function generateBudgetRecommendations(array $financialData): array
    {
        $prompt = $this->createBudgetRecommendationPrompt($financialData);

        $systemPrompt = 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.';

        return $this->generateResponse([
            'prompt' => $prompt,
            'system_prompt' => $systemPrompt,
            'options' => [
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]
        ]);
    }

    /**
     * Generate spending pattern analysis using local Ollama model
     */
    public function generateSpendingPatternAnalysis(array $financialData): array
    {
        $prompt = $this->createSpendingPatternPrompt($financialData);

        $systemPrompt = 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.';

        return $this->generateResponse([
            'prompt' => $prompt,
            'system_prompt' => $systemPrompt,
            'options' => [
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]
        ]);
    }

    /**
     * Create prompt for financial analysis
     */
    private function createFinancialAnalysisPrompt(array $financialData): string
    {
        $income = $financialData['total_income'] ?? 0;
        $expense = $financialData['total_expense'] ?? 0;
        $balance = $income - $expense;
        $savingsRate = $income > 0 ? round(($balance / $income) * 100, 2) : 0;
        $categories = $financialData['categories'] ?? [];

        $categoryStr = '';
        foreach ($categories as $category => $amount) {
            $categoryStr .= "- {$category}: Rp " . number_format($amount, 0, ',', '.') . "\n";
        }

        return "Sebagai seorang ahli keuangan pribadi, analisis data keuangan berikut dan berikan insight yang berguna:

Total Pendapatan: Rp " . number_format($income, 0, ',', '.') . "
Total Pengeluaran: Rp " . number_format($expense, 0, ',', '.') . "
Saldo Bersih: Rp " . number_format($balance, 0, ',', '.') . "
Tingkat Tabungan: {$savingsRate}%

Kategori Pengeluaran:
{$categoryStr}

Berikan analisis dalam format berikut:
1. Ringkasan kondisi keuangan
2. Kategori pengeluaran tertinggi dan rekomendasi untuk menguranginya
3. Saran untuk meningkatkan tabungan
4. Pola pengeluaran yang perlu diperhatikan
5. Tips keuangan personal yang bisa diterapkan

Format jawaban dalam bahasa Indonesia yang mudah dipahami.";
    }

    /**
     * Create prompt for budget recommendations
     */
    private function createBudgetRecommendationPrompt(array $financialData): string
    {
        $income = $financialData['total_income'] ?? 0;
        $categories = $financialData['categories'] ?? [];

        $categoryStr = '';
        foreach ($categories as $category => $amount) {
            $percentage = $income > 0 ? round(($amount / $income) * 100, 2) : 0;
            $categoryStr .= "- {$category}: Rp " . number_format($amount, 0, ',', '.') . " ({$percentage}% dari pendapatan)\n";
        }

        return "Berdasarkan data keuangan berikut, buatkan rekomendasi anggaran bulanan yang sehat:

Total Pendapatan Bulanan: Rp " . number_format($income, 0, ',', '.') . "

Kategori Pengeluaran:
{$categoryStr}

Gunakan aturan 50/30/20 jika sesuai (50% kebutuhan, 30% keinginan, 20% tabungan/investasi) atau aturan lain yang lebih sesuai untuk anak kost. Berikan rekomendasi dalam format:
1. Pembagian anggaran per kategori
2. Batas maksimal pengeluaran per kategori
3. Tips untuk menaati anggaran
4. Cara melacak pengeluaran

Format jawaban dalam bahasa Indonesia.";
    }

    /**
     * Create prompt for spending pattern analysis
     */
    private function createSpendingPatternPrompt(array $financialData): string
    {
        $transactions = $financialData['transactions'] ?? [];
        $dailySpending = $financialData['daily_spending'] ?? [];
        $categories = $financialData['categories'] ?? [];

        $transactionStr = '';
        if (!empty($transactions)) {
            $transactionStr = "Beberapa transaksi terbaru:\n";
            foreach (array_slice($transactions, 0, 5) as $transaction) {
                $transactionStr .= "- {$transaction['date']}: {$transaction['description']} - Rp " . number_format($transaction['amount'], 0, ',', '.') . " ({$transaction['category']})\n";
            }
        }

        $categoryStr = '';
        foreach ($categories as $category => $amount) {
            $categoryStr .= "- {$category}: Rp " . number_format($amount, 0, ',', '.') . "\n";
        }

        $result = "Analisis pola pengeluaran berikut dan identifikasi kebiasaan keuangan:

{$transactionStr}

Kategori Pengeluaran:
{$categoryStr}

Daily Spending Pattern:\n";
        if (!empty($dailySpending)) {
            foreach ($dailySpending as $date => $amount) {
                $result .= "- {$date}: Rp " . number_format($amount, 0, ',', '.') . "\n";
            }
        }

        $result .= "
Identifikasi:
1. Pola pengeluaran harian (tinggi di hari tertentu, tren mingguan)
2. Kategori pengeluaran yang tidak perlu
3. Waktu terbaik untuk pengeluaran besar
4. Tren pengeluaran yang perlu diwaspadai
5. Rekomendasi waktu terbaik untuk menabung

Format jawaban dalam bahasa Indonesia.";

        return $result;
    }

    /**
     * Test the connection to Ollama API
     */
    public function testConnection(): array
    {
        $testPrompt = "Halo, apakah API Ollama berfungsi dengan baik? Jawab dengan singkat dalam bahasa Indonesia.";

        $systemPrompt = 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.';

        return $this->generateResponse([
            'prompt' => $testPrompt,
            'system_prompt' => $systemPrompt,
            'options' => [
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]
        ]);
    }
}