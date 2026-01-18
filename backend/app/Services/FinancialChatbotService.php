<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Repositories\TransactionRepositoryInterface;
use App\Models\ChatbotConversation;

/**
 * Financial Chatbot Service using Qwen AI via OpenRouter
 * Handles processing of financial questions using AI
 * This service replaces the original Gemini service to use OpenRouter with Qwen model
 */
class FinancialChatbotService implements FinancialChatbotServiceInterface
{
    private $geminiService;
    private $transactionRepository;

    public function __construct(GeminiService $geminiService, TransactionRepositoryInterface $transactionRepository)
    {
        $this->geminiService = $geminiService;
        $this->transactionRepository = $transactionRepository;
    }

    /**
     * Process user's financial question and return answer using Qwen AI via OpenRouter
     */
    public function processQuestion(int $userId, string $question): array
    {
        // First, try to extract financial intent from the question
        $intent = $this->analyzeQuestionIntent($question);

        if ($intent['type'] !== 'unknown') {
            // Process the specific financial query
            $result = $this->processSpecificQuery($userId, $question, $intent);

            if ($result) {
                // Save the conversation
                $this->saveConversation($userId, $question, $result, $intent);

                return [
                    'success' => true,
                    'answer' => $result,
                    'intent' => $intent
                ];
            }
        }

        // If specific processing fails, use Qwen AI via OpenRouter for general response
        $response = $this->getGeneralResponse($userId, $question);

        // Save the conversation
        $this->saveConversation($userId, $question, $response['answer'], $response['intent'] ?? []);

        return $response;
    }

    /**
     * Analyze the intent of the financial question for Qwen AI via OpenRouter
     */
    private function analyzeQuestionIntent(string $question): array
    {
        $question = strtolower($question);
        
        // Define patterns for different financial queries
        $patterns = [
            'expense_total' => [
                'keywords' => ['berapa total pengeluaran', 'jumlah pengeluaran', 'total belanja', 'uang yang dikeluarkan'],
                'time_patterns' => ['bulan ini', 'bulan lalu', 'minggu ini', 'minggu lalu', 'tahun ini', 'hari ini', 'kemarin'],
                'category_patterns' => ['makan', 'transportasi', 'laundry', 'hiburan', 'tagihan', 'sekolah', 'kost', 'pulsa', 'bensin', 'belanja']
            ],
            'income_total' => [
                'keywords' => ['berapa total pemasukan', 'jumlah pemasukan', 'total pendapatan', 'uang yang masuk'],
                'time_patterns' => ['bulan ini', 'bulan lalu', 'minggu ini', 'minggu lalu', 'tahun ini', 'hari ini', 'kemarin']
            ],
            'balance' => [
                'keywords' => ['saldo', 'uang saya', 'uang tersisa', 'uang sekarang', 'uang saat ini']
            ],
            'category_expense' => [
                'keywords' => ['pengeluaran untuk', 'uang untuk', 'biaya untuk', 'berapa biaya'],
                'category_patterns' => ['makan', 'transportasi', 'laundry', 'hiburan', 'tagihan', 'sekolah', 'kost', 'pulsa', 'bensin', 'belanja']
            ]
        ];
        
        foreach ($patterns as $type => $pattern) {
            foreach ($pattern['keywords'] as $keyword) {
                if (strpos($question, $keyword) !== false) {
                    $intent = [
                        'type' => $type,
                        'keyword' => $keyword
                    ];
                    
                    // Extract time period if available
                    if (isset($pattern['time_patterns'])) {
                        foreach ($pattern['time_patterns'] as $time) {
                            if (strpos($question, $time) !== false) {
                                $intent['time_period'] = $time;
                                break;
                            }
                        }
                    }
                    
                    // Extract category if available
                    if (isset($pattern['category_patterns'])) {
                        foreach ($pattern['category_patterns'] as $category) {
                            if (strpos($question, $category) !== false) {
                                $intent['category'] = $category;
                                break;
                            }
                        }
                    }
                    
                    return $intent;
                }
            }
        }
        
        return ['type' => 'unknown'];
    }

    /**
     * Process specific financial queries for Qwen AI via OpenRouter
     */
    private function processSpecificQuery(int $userId, string $question, array $intent): ?string
    {
        switch ($intent['type']) {
            case 'expense_total':
                return $this->calculateExpenseTotal($userId, $intent);
            case 'income_total':
                return $this->calculateIncomeTotal($userId, $intent);
            case 'category_expense':
                return $this->calculateCategoryExpense($userId, $intent);
            case 'balance':
                return $this->calculateBalance($userId);
            default:
                return null;
        }
    }

    /**
     * Calculate expense total based on intent for Qwen AI via OpenRouter
     */
    private function calculateExpenseTotal(int $userId, array $intent): string
    {
        $filters = [
            'type' => 'expense',
            'limit' => 1000
        ];
        
        // Add date filters based on time period
        if (isset($intent['time_period'])) {
            $dateRange = $this->getDateRangeFromPeriod($intent['time_period']);
            $filters['start_date'] = $dateRange['start'];
            $filters['end_date'] = $dateRange['end'];
        }
        
        $transactions = $this->transactionRepository->getAll($userId, $filters);
        
        $total = 0;
        foreach ($transactions as $transaction) {
            $total += $transaction->amount;
        }
        
        $timeDesc = $this->getTimeDescription($intent['time_period'] ?? 'unknown');
        return "Total pengeluaran {$timeDesc} adalah Rp " . number_format($total, 0, ',', '.');
    }

    /**
     * Calculate category-specific expense for Qwen AI via OpenRouter
     */
    private function calculateCategoryExpense(int $userId, array $intent): string
    {
        $filters = [
            'type' => 'expense',
            'limit' => 1000
        ];
        
        // Add date filters based on time period
        if (isset($intent['time_period'])) {
            $dateRange = $this->getDateRangeFromPeriod($intent['time_period']);
            $filters['start_date'] = $dateRange['start'];
            $filters['end_date'] = $dateRange['end'];
        }
        
        $transactions = $this->transactionRepository->getAll($userId, $filters);
        
        // Find transactions matching the category
        $categoryTransactions = [];
        $categoryName = $intent['category'] ?? '';
        
        foreach ($transactions as $transaction) {
            $transactionCategory = strtolower($transaction->category->name);
            if (strpos($transactionCategory, $categoryName) !== false) {
                $categoryTransactions[] = $transaction;
            }
        }
        
        $total = array_sum(array_map(function($t) { return $t->amount; }, $categoryTransactions));
        
        $timeDesc = $this->getTimeDescription($intent['time_period'] ?? 'unknown');
        return "Total pengeluaran untuk {$categoryName} {$timeDesc} adalah Rp " . number_format($total, 0, ',', '.');
    }

    /**
     * Calculate income total for Qwen AI via OpenRouter
     */
    private function calculateIncomeTotal(int $userId, array $intent): string
    {
        $filters = [
            'type' => 'income',
            'limit' => 1000
        ];
        
        // Add date filters based on time period
        if (isset($intent['time_period'])) {
            $dateRange = $this->getDateRangeFromPeriod($intent['time_period']);
            $filters['start_date'] = $dateRange['start'];
            $filters['end_date'] = $dateRange['end'];
        }
        
        $transactions = $this->transactionRepository->getAll($userId, $filters);
        
        $total = 0;
        foreach ($transactions as $transaction) {
            $total += $transaction->amount;
        }
        
        $timeDesc = $this->getTimeDescription($intent['time_period'] ?? 'unknown');
        return "Total pemasukan {$timeDesc} adalah Rp " . number_format($total, 0, ',', '.');
    }

    /**
     * Calculate current balance for Qwen AI via OpenRouter
     */
    private function calculateBalance(int $userId): string
    {
        $allTransactions = $this->transactionRepository->getAll($userId, ['limit' => 1000]);
        
        $income = 0;
        $expense = 0;
        
        foreach ($allTransactions as $transaction) {
            if ($transaction->type === 'income') {
                $income += $transaction->amount;
            } else {
                $expense += $transaction->amount;
            }
        }
        
        $balance = $income - $expense;
        
        $balanceText = $balance >= 0 ? "Rp " . number_format($balance, 0, ',', '.') : "Rp " . number_format(abs($balance), 0, ',', '.') . " (defisit)";
        
        return "Saldo Anda saat ini adalah {$balanceText}";
    }

    /**
     * Get date range based on time period for Qwen AI via OpenRouter
     */
    private function getDateRangeFromPeriod(string $period): array
    {
        switch ($period) {
            case 'bulan ini':
                return [
                    'start' => now()->startOfMonth()->format('Y-m-d'),
                    'end' => now()->endOfMonth()->format('Y-m-d')
                ];
            case 'bulan lalu':
                return [
                    'start' => now()->subMonth()->startOfMonth()->format('Y-m-d'),
                    'end' => now()->subMonth()->endOfMonth()->format('Y-m-d')
                ];
            case 'minggu ini':
                return [
                    'start' => now()->startOfWeek()->format('Y-m-d'),
                    'end' => now()->endOfWeek()->format('Y-m-d')
                ];
            case 'minggu lalu':
                return [
                    'start' => now()->subWeek()->startOfWeek()->format('Y-m-d'),
                    'end' => now()->subWeek()->endOfWeek()->format('Y-m-d')
                ];
            case 'tahun ini':
                return [
                    'start' => now()->startOfYear()->format('Y-m-d'),
                    'end' => now()->endOfYear()->format('Y-m-d')
                ];
            case 'hari ini':
                return [
                    'start' => now()->format('Y-m-d'),
                    'end' => now()->format('Y-m-d')
                ];
            case 'kemarin':
                return [
                    'start' => now()->subDay()->format('Y-m-d'),
                    'end' => now()->subDay()->format('Y-m-d')
                ];
            default:
                // Default to current month
                return [
                    'start' => now()->startOfMonth()->format('Y-m-d'),
                    'end' => now()->endOfMonth()->format('Y-m-d')
                ];
        }
    }

    /**
     * Get time period description for Qwen AI via OpenRouter
     */
    private function getTimeDescription(?string $period): string
    {
        switch ($period) {
            case 'bulan ini':
                return 'bulan ini';
            case 'bulan lalu':
                return 'bulan lalu';
            case 'minggu ini':
                return 'minggu ini';
            case 'minggu lalu':
                return 'minggu lalu';
            case 'tahun ini':
                return 'tahun ini';
            case 'hari ini':
                return 'hari ini';
            case 'kemarin':
                return 'kemarin';
            default:
                return 'bulan ini';
        }
    }

    /**
     * Get general response using Qwen AI via OpenRouter when specific processing fails
     */
    private function getGeneralResponse(int $userId, string $question): array
    {
        // Get user's financial data to provide context to Qwen AI
        $recentTransactions = $this->transactionRepository->getAll($userId, [
            'limit' => 20,
            'start_date' => now()->subDays(30)->format('Y-m-d'),
            'end_date' => now()->format('Y-m-d')
        ]);

        $financialSummary = $this->generateFinancialSummary($recentTransactions);

        $prompt = "Sebagai asisten keuangan pribadi, jawab pertanyaan pengguna berikut berdasarkan data keuangan yang tersedia:

Data Keuangan Pengguna:
{$financialSummary}

Pertanyaan: {$question}

Berikan jawaban yang jelas, ringkas, dan dalam bahasa Indonesia yang mudah dimengerti. Jika memungkinkan, sertakan angka atau data spesifik.";

        $geminiResult = $this->geminiService->generateFinancialInsights(['prompt' => $prompt]);

        if ($geminiResult['success']) {
            return [
                'success' => true,
                'answer' => $geminiResult['data']['analysis'] ?? 'Saya memahami pertanyaan Anda, tetapi butuh lebih banyak informasi untuk memberikan jawaban yang akurat.',
                'intent' => ['type' => 'general']
            ];
        } else {
            return [
                'success' => false,
                'answer' => 'Maaf, saya sedang mengalami kendala teknis. Silakan coba lagi nanti.',
                'intent' => ['type' => 'error']
            ];
        }
    }

    /**
     * Generate financial summary from transactions for Qwen AI via OpenRouter
     */
    private function generateFinancialSummary($transactions): string
    {
        if ($transactions->isEmpty()) {
            return "Pengguna belum memiliki data transaksi.";
        }
        
        $income = 0;
        $expense = 0;
        $categories = [];
        
        foreach ($transactions as $transaction) {
            if ($transaction->type === 'income') {
                $income += $transaction->amount;
            } else {
                $expense += $transaction->amount;
                $catName = $transaction->category->name;
                $categories[$catName] = ($categories[$catName] ?? 0) + $transaction->amount;
            }
        }
        
        $summary = "Ringkasan keuangan 30 hari terakhir:\n";
        $summary .= "- Total pemasukan: Rp " . number_format($income, 0, ',', '.') . "\n";
        $summary .= "- Total pengeluaran: Rp " . number_format($expense, 0, ',', '.') . "\n";
        $summary .= "- Sisa saldo: Rp " . number_format($income - $expense, 0, ',', '.') . "\n";
        $summary .= "- Kategori pengeluaran utama: ";
        
        arsort($categories);
        $topCategories = array_slice($categories, 0, 3, true);
        $categoryList = [];
        foreach ($topCategories as $cat => $amount) {
            $categoryList[] = "{$cat} (Rp " . number_format($amount, 0, ',', '.') . ")";
        }
        $summary .= implode(", ", $categoryList) . "\n";
        
        return $summary;
    }

    /**
     * Save conversation to database for Qwen AI via OpenRouter
     */
    private function saveConversation(int $userId, string $question, string $answer, array $intent): void
    {
        try {
            ChatbotConversation::create([
                'user_id' => $userId,
                'user_question' => $question,
                'ai_response' => $answer,
                'intent' => $intent,
                'conversation_type' => 'financial'
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to save chatbot conversation: ' . $e->getMessage());
        }
    }
}