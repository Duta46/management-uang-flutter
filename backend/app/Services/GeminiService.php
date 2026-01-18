<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * AI Service for financial analysis using Qwen model via OpenRouter API
 * This class replaces the original Gemini service to use OpenRouter with Qwen model
 */
class GeminiService
{
    private string $apiKey;
    private string $apiUrl;
    private string $model;

    public function __construct()
    {
        $this->apiKey = env('OPENAI_API_KEY');
        $this->apiUrl = env('OPENAI_BASE_URL', 'https://openrouter.ai/api/v1');
        $this->model = env('OPENAI_MODEL', 'qwen/qwen3-235b-a22b:free');
    }

    /**
     * Generate financial insights using Qwen AI via OpenRouter
     */
    public function generateFinancialInsights(array $financialData): array
    {
        // Check if financialData contains a custom prompt
        if (isset($financialData['prompt'])) {
            $prompt = $financialData['prompt'];
        } else {
            $prompt = $this->createFinancialAnalysisPrompt($financialData);
        }

        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->post($this->apiUrl . '/chat/completions', [
                'model' => $this->model,
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.'
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt
                    ]
                ],
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $text = $data['choices'][0]['message']['content'] ?? '';

                $result = $this->parseResponse($text);

                return [
                    'success' => true,
                    'data' => $result,
                    'raw_response' => $text
                ];
            } else {
                Log::error('OpenRouter API Error: ' . $response->body());

                return [
                    'success' => false,
                    'error' => 'API Error: ' . $response->body(),
                    'data' => null
                ];
            }
        } catch (\Exception $e) {
            Log::error('OpenRouter API Exception: ' . $e->getMessage());

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'data' => null
            ];
        }
    }

    /**
     * Generate budget recommendations using Qwen AI via OpenRouter
     */
    public function generateBudgetRecommendations(array $financialData): array
    {
        $prompt = $this->createBudgetRecommendationPrompt($financialData);

        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->post($this->apiUrl . '/chat/completions', [
                'model' => $this->model,
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.'
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt
                    ]
                ],
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $text = $data['choices'][0]['message']['content'] ?? '';

                $result = $this->parseResponse($text);

                return [
                    'success' => true,
                    'data' => $result,
                    'raw_response' => $text
                ];
            } else {
                Log::error('OpenRouter API Error: ' . $response->body());

                return [
                    'success' => false,
                    'error' => 'API Error: ' . $response->body(),
                    'data' => null
                ];
            }
        } catch (\Exception $e) {
            Log::error('OpenRouter API Exception: ' . $e->getMessage());

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'data' => null
            ];
        }
    }

    /**
     * Generate spending pattern analysis using Qwen AI via OpenRouter
     */
    public function generateSpendingPatternAnalysis(array $financialData): array
    {
        $prompt = $this->createSpendingPatternPrompt($financialData);

        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->post($this->apiUrl . '/chat/completions', [
                'model' => $this->model,
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.'
                    ],
                    [
                        'role' => 'user',
                        'content' => $prompt
                    ]
                ],
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $text = $data['choices'][0]['message']['content'] ?? '';

                $result = $this->parseResponse($text);

                return [
                    'success' => true,
                    'data' => $result,
                    'raw_response' => $text
                ];
            } else {
                Log::error('OpenRouter API Error: ' . $response->body());

                return [
                    'success' => false,
                    'error' => 'API Error: ' . $response->body(),
                    'data' => null
                ];
            }
        } catch (\Exception $e) {
            Log::error('OpenRouter API Exception: ' . $e->getMessage());

            return [
                'success' => false,
                'error' => $e->getMessage(),
                'data' => null
            ];
        }
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
     * Parse the Gemini response into structured data
     */
    private function parseResponse(string $text): array
    {
        // Basic parsing - in real implementation you might want more sophisticated parsing
        return [
            'analysis' => $text,
            'summary' => $this->extractSummary($text),
            'recommendations' => $this->extractRecommendations($text),
            'insights' => $this->extractInsights($text)
        ];
    }

    /**
     * Extract summary from response
     */
    private function extractSummary(string $text): string
    {
        // Simple extraction - in real implementation you might use regex or NLP
        $lines = explode("\n", $text);
        $summary = '';

        foreach ($lines as $line) {
            if (stripos($line, 'ringkasan') !== false || stripos($line, 'summary') !== false) {
                $summary .= $line . ' ';
            }
        }

        return $summary ?: 'Analisis keuangan telah selesai.';
    }

    /**
     * Extract recommendations from response
     */
    private function extractRecommendations(string $text): array
    {
        $recommendations = [];
        $lines = explode("\n", $text);

        foreach ($lines as $line) {
            if (
                stripos($line, 'rekomendasi') !== false ||
                stripos($line, 'sar') !== false ||
                stripos($line, 'tips') !== false
            ) {
                $recommendations[] = trim(str_replace(['1.', '2.', '3.', '4.', '5.', '6.', '7.', '8.', '9.', '0.'], '', $line));
            }
        }

        return $recommendations;
    }

    /**
     * Extract insights from response
     */
    private function extractInsights(string $text): array
    {
        $insights = [];
        $lines = explode("\n", $text);

        foreach ($lines as $line) {
            if (
                stripos($line, 'pola') !== false ||
                stripos($line, 'tren') !== false ||
                stripos($line, 'analisis') !== false
            ) {
                $insights[] = trim($line);
            }
        }

        return $insights;
    }

    /**
     * Test the connection to OpenRouter API
     */
    public function testConnection(): array
    {
        $testPrompt = "Halo, apakah API OpenRouter berfungsi dengan baik? Jawab dengan singkat dalam bahasa Indonesia.";

        try {
            $response = Http::withHeaders([
                'Content-Type' => 'application/json',
                'Authorization' => 'Bearer ' . $this->apiKey,
            ])->post($this->apiUrl . '/chat/completions', [
                'model' => $this->model,
                'messages' => [
                    [
                        'role' => 'system',
                        'content' => 'Kamu adalah asisten keuangan pribadi. Jawaban harus singkat, jelas, dan mudah dipahami. Jangan memberikan saran investasi berisiko. Gunakan bahasa Indonesia yang profesional dan ramah.'
                    ],
                    [
                        'role' => 'user',
                        'content' => $testPrompt
                    ]
                ],
                'temperature' => 0.7,
                'max_tokens' => 2048,
            ]);

            if ($response->successful()) {
                $data = $response->json();
                $text = $data['choices'][0]['message']['content'] ?? '';

                return [
                    'success' => true,
                    'message' => 'Koneksi ke OpenRouter API berhasil',
                    'response' => $text
                ];
            } else {
                Log::error('OpenRouter API Test Error: ' . $response->body());

                return [
                    'success' => false,
                    'message' => 'Koneksi ke OpenRouter API gagal: ' . $response->body(),
                    'response' => null
                ];
            }
        } catch (\Exception $e) {
            Log::error('OpenRouter API Test Exception: ' . $e->getMessage());

            return [
                'success' => false,
                'message' => 'Kesalahan saat menguji koneksi: ' . $e->getMessage(),
                'response' => null
            ];
        }
    }
}
