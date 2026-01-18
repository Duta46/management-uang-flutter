<?php

namespace App\Services;

use App\Models\AiAnalysis;
use App\Repositories\TransactionRepositoryInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use App\Services\GeminiService;

/**
 * AI Analysis Service for financial insights
 * Uses OpenRouter API with Qwen model for financial analysis
 * This service replaces the original Gemini service to use OpenRouter with Qwen model
 */
class AiAnalysisService implements AiAnalysisServiceInterface
{
    private TransactionRepositoryInterface $transactionRepository;
    private GeminiService $geminiService;

    public function __construct(TransactionRepositoryInterface $transactionRepository, GeminiService $geminiService)
    {
        $this->transactionRepository = $transactionRepository;
        $this->geminiService = $geminiService;
    }

    /**
     * Get financial insights using Qwen AI via OpenRouter
     */
    public function getFinancialInsights(int $userId, string $analysisType, array $dateRange): array
    {
        // Get user's transactions for the specified date range
        $transactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $dateRange['start_date'],
            'end_date' => $dateRange['end_date'],
            'limit' => 1000 // Limit to avoid too much data
        ]);

        // Calculate basic financial metrics
        $totalIncome = 0;
        $totalExpense = 0;
        $categoryExpenses = [];
        $dailyExpenses = [];
        $incomeByCategory = [];
        $transactionList = [];

        foreach ($transactions as $transaction) {
            // Store transaction details for Gemini analysis
            $transactionList[] = [
                'date' => $transaction->date->format('Y-m-d'),
                'description' => $transaction->description,
                'amount' => $transaction->amount,
                'category' => $transaction->category->name,
                'type' => $transaction->type
            ];

            if ($transaction->type === 'income') {
                $totalIncome += $transaction->amount;

                // Group income by category
                $categoryName = $transaction->category->name;
                $incomeByCategory[$categoryName] = ($incomeByCategory[$categoryName] ?? 0) + $transaction->amount;
            } else {
                $totalExpense += $transaction->amount;

                // Group expenses by category
                $categoryName = $transaction->category->name;
                $categoryExpenses[$categoryName] = ($categoryExpenses[$categoryName] ?? 0) + $transaction->amount;

                // Group expenses by date
                $date = $transaction->date->format('Y-m-d');
                $dailyExpenses[$date] = ($dailyExpenses[$date] ?? 0) + $transaction->amount;
            }
        }

        // Prepare financial data for Gemini analysis
        $financialData = [
            'total_income' => $totalIncome,
            'total_expense' => $totalExpense,
            'categories' => $categoryExpenses,
            'income_categories' => $incomeByCategory,
            'transactions' => $transactionList,
            'daily_spending' => $dailyExpenses,
            'user_id' => $userId
        ];

        // Use Gemini API to generate insights
        $geminiResult = $this->geminiService->generateFinancialInsights($financialData);

        if ($geminiResult['success']) {
            // Combine Gemini insights with calculated metrics
            return [
                'summary' => [
                    'total_income' => $totalIncome,
                    'total_expense' => $totalExpense,
                    'net_balance' => $totalIncome - $totalExpense,
                    'savings_rate' => $totalIncome > 0 ? round(($totalIncome - $totalExpense) / $totalIncome * 100, 2) : 0
                ],
                'income_breakdown' => $incomeByCategory,
                'expense_breakdown' => $categoryExpenses,
                'top_expense_categories' => $this->getTopCategories($categoryExpenses, 5),
                'top_income_categories' => $this->getTopCategories($incomeByCategory, 5),
                'daily_spending_trend' => $this->getDailySpendingTrend($dailyExpenses),
                'monthly_comparison' => $this->getMonthlyComparison($userId, $dateRange),
                'gemini_insights' => $geminiResult['data'],
                'recommendations' => $this->generateRecommendations($totalIncome, $totalExpense, $categoryExpenses)
            ];
        } else {
            // Fallback to basic analysis if Gemini fails
            return [
                'summary' => [
                    'total_income' => $totalIncome,
                    'total_expense' => $totalExpense,
                    'net_balance' => $totalIncome - $totalExpense,
                    'savings_rate' => $totalIncome > 0 ? round(($totalIncome - $totalExpense) / $totalIncome * 100, 2) : 0
                ],
                'income_breakdown' => $incomeByCategory,
                'expense_breakdown' => $categoryExpenses,
                'top_expense_categories' => $this->getTopCategories($categoryExpenses, 5),
                'top_income_categories' => $this->getTopCategories($incomeByCategory, 5),
                'daily_spending_trend' => $this->getDailySpendingTrend($dailyExpenses),
                'monthly_comparison' => $this->getMonthlyComparison($userId, $dateRange),
                'gemini_insights' => null,
                'recommendations' => $this->generateRecommendations($totalIncome, $totalExpense, $categoryExpenses)
            ];
        }
    }

    /**
     * Get spending pattern analysis using Qwen AI via OpenRouter
     */
    public function getSpendingPatternAnalysis(int $userId, array $dateRange): array
    {
        $transactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $dateRange['start_date'],
            'end_date' => $dateRange['end_date'],
            'type' => 'expense',
            'limit' => 1000
        ]);

        $categoryExpenses = [];
        $weeklyPattern = [];
        $monthlyPattern = [];
        $transactionList = [];

        foreach ($transactions as $transaction) {
            // Store transaction details for Gemini analysis
            $transactionList[] = [
                'date' => $transaction->date->format('Y-m-d'),
                'description' => $transaction->description,
                'amount' => $transaction->amount,
                'category' => $transaction->category->name,
                'type' => $transaction->type
            ];

            $categoryName = $transaction->category->name;
            $categoryExpenses[$categoryName] = ($categoryExpenses[$categoryName] ?? 0) + $transaction->amount;

            // Group by week
            $week = $transaction->date->format('Y-W');
            $weeklyPattern[$week] = ($weeklyPattern[$week] ?? 0) + $transaction->amount;

            // Group by month
            $month = $transaction->date->format('Y-m');
            $monthlyPattern[$month] = ($monthlyPattern[$month] ?? 0) + $transaction->amount;
        }

        // Prepare financial data for Gemini analysis
        $financialData = [
            'total_expense' => array_sum($categoryExpenses),
            'categories' => $categoryExpenses,
            'transactions' => $transactionList,
            'daily_spending' => [], // We can enhance this with daily data if needed
            'user_id' => $userId
        ];

        // Use Gemini API to generate spending pattern analysis
        $geminiResult = $this->geminiService->generateSpendingPatternAnalysis($financialData);

        if ($geminiResult['success']) {
            return [
                'category_breakdown' => $categoryExpenses,
                'weekly_spending' => $weeklyPattern,
                'monthly_spending' => $monthlyPattern,
                'pattern_insights' => $this->analyzeSpendingPatterns($categoryExpenses, $weeklyPattern),
                'gemini_analysis' => $geminiResult['data']
            ];
        } else {
            // Fallback to basic analysis if Gemini fails
            return [
                'category_breakdown' => $categoryExpenses,
                'weekly_spending' => $weeklyPattern,
                'monthly_spending' => $monthlyPattern,
                'pattern_insights' => $this->analyzeSpendingPatterns($categoryExpenses, $weeklyPattern),
                'gemini_analysis' => null
            ];
        }
    }

    /**
     * Get budget recommendations using Qwen AI via OpenRouter
     */
    public function getBudgetRecommendations(int $userId, array $dateRange): array
    {
        $transactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $dateRange['start_date'],
            'end_date' => $dateRange['end_date'],
            'limit' => 1000
        ]);

        $categoryExpenses = [];
        $totalExpense = 0;
        $totalIncome = 0;
        $transactionList = [];

        foreach ($transactions as $transaction) {
            // Store transaction details for Gemini analysis
            $transactionList[] = [
                'date' => $transaction->date->format('Y-m-d'),
                'description' => $transaction->description,
                'amount' => $transaction->amount,
                'category' => $transaction->category->name,
                'type' => $transaction->type
            ];

            if ($transaction->type === 'expense') {
                $categoryName = $transaction->category->name;
                $categoryExpenses[$categoryName] = ($categoryExpenses[$categoryName] ?? 0) + $transaction->amount;
                $totalExpense += $transaction->amount;
            } else {
                $totalIncome += $transaction->amount;
            }
        }

        // Prepare financial data for Gemini analysis
        $financialData = [
            'total_income' => $totalIncome,
            'total_expense' => $totalExpense,
            'categories' => $categoryExpenses,
            'transactions' => $transactionList,
            'user_id' => $userId
        ];

        // Use Gemini API to generate budget recommendations
        $geminiResult = $this->geminiService->generateBudgetRecommendations($financialData);

        if ($geminiResult['success']) {
            // Calculate recommended budgets based on spending patterns
            $recommendations = [];
            foreach ($categoryExpenses as $category => $amount) {
                $percentage = round(($amount / $totalExpense) * 100, 2);

                // Suggest 10% reduction as a starting point for budgeting
                $recommendedBudget = $amount * 0.9;

                $recommendations[] = [
                    'category' => $category,
                    'current_spending' => $amount,
                    'recommended_budget' => $recommendedBudget,
                    'percentage_of_total' => $percentage,
                    'savings_potential' => $amount - $recommendedBudget
                ];
            }

            return [
                'total_income' => $totalIncome,
                'total_expense' => $totalExpense,
                'category_recommendations' => $recommendations,
                'total_savings_potential' => array_sum(array_column($recommendations, 'savings_potential')),
                'gemini_recommendations' => $geminiResult['data']
            ];
        } else {
            // Fallback to basic analysis if Gemini fails
            $recommendations = [];
            foreach ($categoryExpenses as $category => $amount) {
                $percentage = round(($amount / $totalExpense) * 100, 2);

                // Suggest 10% reduction as a starting point for budgeting
                $recommendedBudget = $amount * 0.9;

                $recommendations[] = [
                    'category' => $category,
                    'current_spending' => $amount,
                    'recommended_budget' => $recommendedBudget,
                    'percentage_of_total' => $percentage,
                    'savings_potential' => $amount - $recommendedBudget
                ];
            }

            return [
                'total_income' => $totalIncome,
                'total_expense' => $totalExpense,
                'category_recommendations' => $recommendations,
                'total_savings_potential' => array_sum(array_column($recommendations, 'savings_potential')),
                'gemini_recommendations' => null
            ];
        }
    }

    /**
     * Get savings insights using Qwen AI via OpenRouter
     */
    public function getSavingsInsights(int $userId, array $dateRange): array
    {
        $transactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $dateRange['start_date'],
            'end_date' => $dateRange['end_date'],
            'limit' => 1000
        ]);

        $totalIncome = 0;
        $totalExpense = 0;
        $savings = 0;
        $transactionList = [];

        foreach ($transactions as $transaction) {
            // Store transaction details for Gemini analysis
            $transactionList[] = [
                'date' => $transaction->date->format('Y-m-d'),
                'description' => $transaction->description,
                'amount' => $transaction->amount,
                'category' => $transaction->category->name,
                'type' => $transaction->type
            ];

            if ($transaction->type === 'income') {
                $totalIncome += $transaction->amount;
            } else {
                $totalExpense += $transaction->amount;
            }
        }

        $savings = $totalIncome - $totalExpense;
        $savingsRate = $totalIncome > 0 ? round(($savings / $totalIncome) * 100, 2) : 0;

        // Calculate potential savings based on expense categories
        $expenseTransactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $dateRange['start_date'],
            'end_date' => $dateRange['end_date'],
            'type' => 'expense',
            'limit' => 1000
        ]);

        $categoryExpenses = [];
        foreach ($expenseTransactions as $transaction) {
            $categoryName = $transaction->category->name;
            $categoryExpenses[$categoryName] = ($categoryExpenses[$categoryName] ?? 0) + $transaction->amount;
        }

        // Prepare financial data for Gemini analysis
        $financialData = [
            'total_income' => $totalIncome,
            'total_expense' => $totalExpense,
            'categories' => $categoryExpenses,
            'transactions' => $transactionList,
            'user_id' => $userId
        ];

        // Use Gemini API to generate financial insights (which includes savings analysis)
        $geminiResult = $this->geminiService->generateFinancialInsights($financialData);

        // Identify categories where user might save money
        $potentialSavings = $this->identifyPotentialSavings($categoryExpenses);

        if ($geminiResult['success']) {
            return [
                'current_savings' => $savings,
                'savings_rate' => $savingsRate,
                'total_income' => $totalIncome,
                'total_expense' => $totalExpense,
                'potential_savings' => $potentialSavings,
                'savings_tips' => $this->generateSavingsTips($savingsRate, $categoryExpenses),
                'gemini_savings_insights' => $geminiResult['data']
            ];
        } else {
            return [
                'current_savings' => $savings,
                'savings_rate' => $savingsRate,
                'total_income' => $totalIncome,
                'total_expense' => $totalExpense,
                'potential_savings' => $potentialSavings,
                'savings_tips' => $this->generateSavingsTips($savingsRate, $categoryExpenses),
                'gemini_savings_insights' => null
            ];
        }
    }

    /**
     * Generate custom analysis using Qwen AI via OpenRouter
     */
    public function generateAnalysis(int $userId, string $analysisType, array $dateRange): array
    {
        switch ($analysisType) {
            case 'spending_pattern':
                return $this->getSpendingPatternAnalysis($userId, $dateRange);
            case 'budget_recommendation':
                return $this->getBudgetRecommendations($userId, $dateRange);
            case 'savings_insight':
                return $this->getSavingsInsights($userId, $dateRange);
            default:
                return $this->getFinancialInsights($userId, $analysisType, $dateRange);
        }
    }
}

    private function getTopCategories(array $categories, int $limit = 5): array
    {
        arsort($categories);
        return array_slice($categories, 0, $limit, true);
    }

    private function getDailySpendingTrend(array $dailyExpenses): array
    {
        if (empty($dailyExpenses)) {
            return [];
        }

        // Sort by date
        ksort($dailyExpenses);

        $dates = array_keys($dailyExpenses);
        $values = array_values($dailyExpenses);

        // Calculate average
        $average = array_sum($values) / count($values);

        // Identify trend
        $trend = 'stable';
        if (count($values) >= 2) {
            $recentAvg = array_sum(array_slice($values, -3)) / min(3, count($values));
            $olderAvg = array_sum(array_slice($values, 0, 3)) / min(3, count($values));

            if ($recentAvg > $olderAvg * 1.1) {
                $trend = 'increasing';
            } elseif ($recentAvg < $olderAvg * 0.9) {
                $trend = 'decreasing';
            }
        }

        return [
            'average_daily_spending' => $average,
            'trend' => $trend,
            'daily_values' => $dailyExpenses
        ];
    }

    private function generateRecommendations(float $totalIncome, float $totalExpense, array $categoryExpenses): array
    {
        $recommendations = [];

        if ($totalIncome > 0) {
            $savingsRate = ($totalIncome - $totalExpense) / $totalIncome * 100;

            if ($savingsRate < 10) {
                $recommendations[] = "Pertimbangkan untuk menabung minimal 10% dari penghasilan Anda. Saat ini rasio tabungan Anda adalah {$savingsRate}%.";
            } else {
                $recommendations[] = "Rasio tabungan Anda sebesar {$savingsRate}% sudah baik. Pertahankan kebiasaan ini!";
            }
        }

        // Identify high expense categories
        arsort($categoryExpenses);
        $topExpenses = array_slice($categoryExpenses, 0, 3, true);

        foreach ($topExpenses as $category => $amount) {
            $percentage = round(($amount / $totalExpense) * 100, 2);
            if ($percentage > 30) {
                $recommendations[] = "Pengeluaran untuk kategori '{$category}' sebesar {$percentage}% dari total pengeluaran Anda tergolong tinggi. Pertimbangkan untuk menguranginya.";
            }
        }

        return $recommendations;
    }

    private function analyzeSpendingPatterns(array $categoryExpenses, array $weeklyPattern): array
    {
        $insights = [];

        // Identify dominant categories
        arsort($categoryExpenses);
        $topCategory = key($categoryExpenses);
        $topAmount = reset($categoryExpenses);

        if ($topAmount > array_sum($categoryExpenses) * 0.4) {
            $insights[] = "Anda menghabiskan lebih dari 40% pengeluaran untuk kategori '{$topCategory}'. Mungkin bisa dicari alternatif yang lebih hemat.";
        }

        // Analyze weekly patterns
        if (count($weeklyPattern) > 1) {
            $values = array_values($weeklyPattern);
            $avg = array_sum($values) / count($values);
            $max = max($values);
            $min = min($values);

            if ($max > $avg * 1.5) {
                $insights[] = "Anda memiliki minggu dengan pengeluaran jauh di atas rata-rata. Cek kembali pengeluaran minggu tersebut.";
            }
        }

        return $insights;
    }

    private function identifyPotentialSavings(array $categoryExpenses): array
    {
        $potentialSavings = [];

        foreach ($categoryExpenses as $category => $amount) {
            // For demonstration, assume 10% potential saving in each category
            // In a real implementation, this would be more sophisticated
            $potentialSavings[] = [
                'category' => $category,
                'current_spending' => $amount,
                'potential_savings' => $amount * 0.1,
                'savings_percentage' => 10
            ];
        }

        return $potentialSavings;
    }

    private function getMonthlyComparison(int $userId, array $dateRange): array
    {
        // Get transactions for the previous month for comparison
        $currentStart = new \DateTime($dateRange['start_date']);
        $currentEnd = new \DateTime($dateRange['end_date']);

        // Calculate previous period (same length as current)
        $interval = $currentStart->diff($currentEnd);
        $prevEnd = clone $currentStart;
        $prevEnd->sub(new \DateInterval('P1D')); // Day before current period starts
        $prevStart = clone $prevEnd;
        $prevStart->sub($interval);

        // Get current period transactions
        $currentTransactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $dateRange['start_date'],
            'end_date' => $dateRange['end_date'],
            'limit' => 1000
        ]);

        // Get previous period transactions
        $previousTransactions = $this->transactionRepository->getAll($userId, [
            'start_date' => $prevStart->format('Y-m-d'),
            'end_date' => $prevEnd->format('Y-m-d'),
            'limit' => 1000
        ]);

        $currentIncome = 0;
        $currentExpense = 0;
        $previousIncome = 0;
        $previousExpense = 0;

        foreach ($currentTransactions as $transaction) {
            if ($transaction->type === 'income') {
                $currentIncome += $transaction->amount;
            } else {
                $currentExpense += $transaction->amount;
            }
        }

        foreach ($previousTransactions as $transaction) {
            if ($transaction->type === 'income') {
                $previousIncome += $transaction->amount;
            } else {
                $previousExpense += $transaction->amount;
            }
        }

        // Calculate changes
        $incomeChange = $currentIncome - $previousIncome;
        $incomeChangePercent = $previousIncome > 0 ? round(($incomeChange / $previousIncome) * 100, 2) : 0;

        $expenseChange = $currentExpense - $previousExpense;
        $expenseChangePercent = $previousExpense > 0 ? round(($expenseChange / $previousExpense) * 100, 2) : 0;

        return [
            'current_period' => [
                'start_date' => $dateRange['start_date'],
                'end_date' => $dateRange['end_date'],
                'income' => $currentIncome,
                'expense' => $currentExpense,
                'net' => $currentIncome - $currentExpense
            ],
            'previous_period' => [
                'start_date' => $prevStart->format('Y-m-d'),
                'end_date' => $prevEnd->format('Y-m-d'),
                'income' => $previousIncome,
                'expense' => $previousExpense,
                'net' => $previousIncome - $previousExpense
            ],
            'changes' => [
                'income_change' => $incomeChange,
                'income_change_percent' => $incomeChangePercent,
                'expense_change' => $expenseChange,
                'expense_change_percent' => $expenseChangePercent
            ],
            'trend' => [
                'income_trend' => $incomeChange >= 0 ? 'increasing' : 'decreasing',
                'expense_trend' => $expenseChange >= 0 ? 'increasing' : 'decreasing'
            ]
        ];
    }

    private function generateSavingsTips(float $savingsRate, array $categoryExpenses): array
    {
        $tips = [];

        if ($savingsRate < 10) {
            $tips[] = "Coba sisihkan minimal 10% dari penghasilan Anda untuk ditabung";
        } elseif ($savingsRate >= 10 && $savingsRate < 20) {
            $tips[] = "Pertahankan kebiasaan menabung! Coba tingkatkan menjadi 20% jika memungkinkan";
        } else {
            $tips[] = "Luar biasa! Rasio tabungan Anda sudah sangat baik";
        }

        // Find the highest expense category and suggest optimization
        arsort($categoryExpenses);
        $topCategory = key($categoryExpenses);

        if ($topCategory) {
            $tips[] = "Perhatikan pengeluaran untuk '{$topCategory}' karena merupakan pengeluaran terbesar Anda";
            $tips[] = "Cari alternatif yang lebih hemat untuk kategori '{$topCategory}'";
        }

        return $tips;
    }

    /**
     * Test OpenRouter API connection with Qwen model
     */
    public function testGeminiConnection(): array
    {
        return $this->geminiService->testConnection();
    }
}
