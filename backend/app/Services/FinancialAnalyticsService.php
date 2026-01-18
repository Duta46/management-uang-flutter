<?php

namespace App\Services;

use App\Models\Budget;
use App\Models\SavingsGoal;
use App\Models\BillReminder;
use App\Models\FinancialInsight;
use App\Models\Transaction;
use Carbon\Carbon;

class FinancialAnalyticsService
{
    /**
     * Menghasilkan wawasan keuangan berdasarkan pola pengeluaran pengguna
     */
    public function generateFinancialInsights(int $userId)
    {
        $insights = [];

        // Wawasan 1: Analisis pola pengeluaran
        $spendingTrend = $this->analyzeSpendingTrend($userId);
        if ($spendingTrend['is_increasing']) {
            $insights[] = [
                'type' => 'warning',
                'title' => 'Pengeluaran meningkat',
                'message' => 'Pengeluaran Anda meningkat ' . $spendingTrend['percentage_increase'] . '% dalam 3 bulan terakhir. Pertimbangkan untuk meninjau anggaran Anda.',
                'priority' => 'high',
                'data' => [
                    'current_spending' => $spendingTrend['current_spending'],
                    'previous_spending' => $spendingTrend['previous_spending'],
                    'percentage_increase' => $spendingTrend['percentage_increase']
                ]
            ];
        }

        // Wawasan 2: Kepatuhan anggaran
        $budgetAdherence = $this->analyzeBudgetAdherence($userId);
        if ($budgetAdherence['over_budget_categories']) {
            $categories = implode(', ', $budgetAdherence['over_budget_categories']);
            $insights[] = [
                'type' => 'warning',
                'title' => 'Melebihi anggaran',
                'message' => 'Anda melebihi anggaran pada kategori: ' . $categories,
                'priority' => 'medium',
                'data' => [
                    'over_budget_categories' => $budgetAdherence['over_budget_categories']
                ]
            ];
        }

        // Wawasan 3: Progres tabungan
        $savingsProgress = $this->analyzeSavingsProgress($userId);
        if ($savingsProgress['is_slow']) {
            $insights[] = [
                'type' => 'info',
                'title' => 'Progres tabungan lambat',
                'message' => 'Progres tabungan Anda lebih lambat dari target. Pertimbangkan untuk menambah jumlah simpanan bulanan.',
                'priority' => 'low',
                'data' => [
                    'slow_goals' => $savingsProgress['slow_goals']
                ]
            ];
        }

        // Wawasan 4: Tagihan mendatang
        $upcomingBills = $this->analyzeUpcomingBills($userId);
        if ($upcomingBills['overdue_count'] > 0) {
            $insights[] = [
                'type' => 'critical',
                'title' => 'Tagihan terlambat',
                'message' => 'Anda memiliki ' . $upcomingBills['overdue_count'] . ' tagihan yang terlambat. Segera lakukan pembayaran.',
                'priority' => 'critical',
                'data' => [
                    'overdue_count' => $upcomingBills['overdue_count'],
                    'overdue_bills' => $upcomingBills['overdue_bills']
                ]
            ];
        }

        // Wawasan 5: Analisis pengeluaran kategori
        $categoryAnalysis = $this->analyzeCategorySpending($userId);
        if ($categoryAnalysis['highest_spending_category']) {
            $insights[] = [
                'type' => 'info',
                'title' => 'Kategori pengeluaran tertinggi',
                'message' => 'Kategori dengan pengeluaran tertinggi Anda adalah ' . $categoryAnalysis['highest_spending_category']['name'] . ' sebesar Rp ' . number_format($categoryAnalysis['highest_spending_category']['amount'], 0, ',', '.'),
                'priority' => 'low',
                'data' => [
                    'highest_spending_category' => $categoryAnalysis['highest_spending_category']
                ]
            ];
        }

        // Wawasan 6: Potensi penghematan
        $potentialSavings = $this->analyzePotentialSavings($userId);
        if ($potentialSavings['amount'] > 0) {
            $insights[] = [
                'type' => 'info',
                'title' => 'Potensi penghematan',
                'message' => 'Anda bisa menghemat sekitar Rp ' . number_format($potentialSavings['amount'], 0, ',', '.') . ' per bulan dengan mengurangi pengeluaran pada kategori ' . $potentialSavings['category'],
                'priority' => 'medium',
                'data' => [
                    'potential_savings' => $potentialSavings
                ]
            ];
        }

        // Simpan wawasan ke database
        $this->saveInsightsToDatabase($userId, $insights);

        return $insights;
    }

    /**
     * Simpan wawasan ke database
     */
    private function saveInsightsToDatabase(int $userId, array $insights)
    {
        // Hapus wawasan lama (lebih dari 7 hari)
        FinancialInsight::where('user_id', $userId)
            ->where('generated_at', '<', Carbon::now()->subDays(7))
            ->delete();

        foreach ($insights as $insight) {
            FinancialInsight::create([
                'user_id' => $userId,
                'type' => $insight['type'],
                'title' => $insight['title'],
                'message' => $insight['message'],
                'priority' => $insight['priority'],
                'data' => $insight['data'],
                'is_read' => false,
                'generated_at' => Carbon::now()
            ]);
        }
    }

    /**
     * Dapatkan wawasan yang belum dibaca untuk pengguna
     */
    public function getUnreadInsights(int $userId)
    {
        return FinancialInsight::where('user_id', $userId)
            ->where('is_read', false)
            ->orderBy('priority', 'desc')
            ->orderBy('generated_at', 'desc')
            ->get();
    }

    /**
     * Tandai wawasan sebagai sudah dibaca
     */
    public function markInsightAsRead(int $insightId, int $userId)
    {
        $insight = FinancialInsight::where('id', $insightId)
            ->where('user_id', $userId)
            ->first();

        if ($insight) {
            $insight->update(['is_read' => true]);
            return true;
        }

        return false;
    }

    /**
     * Analyze spending trend over time
     */
    private function analyzeSpendingTrend(int $userId)
    {
        $currentMonth = Carbon::now()->startOfMonth();
        $threeMonthsAgo = Carbon::now()->subMonths(3)->startOfMonth();

        $currentSpending = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('date', [$currentMonth, Carbon::now()])
            ->sum('amount');

        $threeMonthsAgoSpending = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('date', [$threeMonthsAgo, $currentMonth->copy()->subDay()])
            ->sum('amount');

        $isIncreasing = $threeMonthsAgoSpending > 0 && $currentSpending > $threeMonthsAgoSpending;
        $percentageIncrease = $threeMonthsAgoSpending > 0
            ? round((($currentSpending - $threeMonthsAgoSpending) / $threeMonthsAgoSpending) * 100, 2)
            : 0;

        return [
            'is_increasing' => $isIncreasing,
            'percentage_increase' => $percentageIncrease,
            'current_spending' => $currentSpending,
            'previous_spending' => $threeMonthsAgoSpending
        ];
    }

    /**
     * Analyze budget adherence
     */
    private function analyzeBudgetAdherence(int $userId)
    {
        $currentMonth = Carbon::now()->format('Y-m');

        $budgets = Budget::where('user_id', $userId)
            ->where('month', $currentMonth)
            ->get();

        $overBudgetCategories = [];

        foreach ($budgets as $budget) {
            if ($budget->spent_amount > $budget->amount) {
                $categoryName = $budget->category ? $budget->category->name : 'Umum';
                $overBudgetCategories[] = $categoryName;
            }
        }

        return [
            'over_budget_categories' => $overBudgetCategories
        ];
    }

    /**
     * Analyze savings progress
     */
    private function analyzeSavingsProgress(int $userId)
    {
        $savingsGoals = SavingsGoal::where('user_id', $userId)
            ->where('status', 'active')
            ->get();

        $isSlow = false;
        $slowGoals = [];

        foreach ($savingsGoals as $goal) {
            $targetDate = Carbon::parse($goal->target_date);
            $daysRemaining = $targetDate->diffInDays(Carbon::today());
            $amountRemaining = $goal->target_amount - $goal->current_amount;

            if ($daysRemaining > 0) {
                $requiredDailySavings = $amountRemaining / $daysRemaining;
                $currentDailySavings = $goal->current_amount / (Carbon::today()->diffInDays(Carbon::parse($goal->created_at)) + 1);

                if ($currentDailySavings < $requiredDailySavings * 0.7) {
                    $isSlow = true;
                    $slowGoals[] = [
                        'goal_name' => $goal->name,
                        'current_amount' => $goal->current_amount,
                        'target_amount' => $goal->target_amount,
                        'days_remaining' => $daysRemaining
                    ];
                }
            }
        }

        return [
            'is_slow' => $isSlow,
            'slow_goals' => $slowGoals
        ];
    }

    /**
     * Analyze upcoming bills
     */
    private function analyzeUpcomingBills(int $userId)
    {
        $overdueBills = BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->where('due_date', '<', Carbon::today())
            ->get();

        return [
            'overdue_count' => $overdueBills->count(),
            'overdue_bills' => $overdueBills->map(function($bill) {
                return [
                    'name' => $bill->name,
                    'amount' => $bill->amount,
                    'due_date' => $bill->due_date,
                    'days_overdue' => Carbon::today()->diffInDays(Carbon::parse($bill->due_date))
                ];
            })->toArray()
        ];
    }

    /**
     * Analyze category spending
     */
    private function analyzeCategorySpending(int $userId)
    {
        $currentMonth = Carbon::now()->format('Y-m');

        $expenses = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('date', Carbon::now()->month)
            ->whereYear('date', Carbon::now()->year)
            ->with('category')
            ->get();

        $categorySpending = [];

        foreach ($expenses as $expense) {
            $categoryName = $expense->category ? $expense->category->name : 'Tidak Berkategori';
            if (!isset($categorySpending[$categoryName])) {
                $categorySpending[$categoryName] = 0;
            }
            $categorySpending[$categoryName] += $expense->amount;
        }

        $highestSpendingCategory = null;
        if (!empty($categorySpending)) {
            $maxSpending = max($categorySpending);
            $maxCategory = array_search($maxSpending, $categorySpending);
            $highestSpendingCategory = [
                'name' => $maxCategory,
                'amount' => $maxSpending
            ];
        }

        return [
            'highest_spending_category' => $highestSpendingCategory
        ];
    }

    /**
     * Analyze potential savings
     */
    private function analyzePotentialSavings(int $userId)
    {
        // Find categories where user spends significantly more than average
        $currentMonth = Carbon::now()->format('Y-m');

        // Get user's spending for each category in current month
        $userCategorySpending = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('date', Carbon::now()->month)
            ->whereYear('date', Carbon::now()->year)
            ->with('category')
            ->get()
            ->groupBy('category_id')
            ->map(function ($transactions) {
                return $transactions->sum('amount');
            });

        // For demo purposes, we'll identify the highest spending category as potential savings
        // In a real app, we would compare to benchmarks or user's historical data
        $maxSpending = $userCategorySpending->max();
        $maxCategory = $userCategorySpending->search($maxSpending);

        // Assume 20% of highest spending category could be reduced
        $potentialSavings = $maxSpending * 0.2;

        $categoryName = 'lainnya';
        if ($maxCategory) {
            $category = \App\Models\Category::find($maxCategory);
            $categoryName = $category ? $category->name : 'lainnya';
        }

        return [
            'amount' => $potentialSavings,
            'category' => $categoryName
        ];
    }

    /**
     * Generate budget recommendations based on spending patterns
     */
    public function generateBudgetRecommendations(int $userId)
    {
        $recommendations = [];

        // Get average spending per category for the last 3 months
        $threeMonthsAgo = Carbon::now()->subMonths(3)->startOfMonth();

        $categorySpending = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->where('date', '>=', $threeMonthsAgo)
            ->with('category')
            ->get()
            ->groupBy('category_id')
            ->map(function ($transactions) {
                return [
                    'category_name' => $transactions->first()->category ? $transactions->first()->category->name : 'Tidak Berkategori',
                    'total_spent' => $transactions->sum('amount'),
                    'average_monthly' => $transactions->sum('amount') / 3
                ];
            });

        foreach ($categorySpending as $categoryId => $data) {
            $recommendedBudget = round($data['average_monthly'] * 1.1); // Add 10% buffer
            $currentBudget = $this->getCurrentBudgetForCategory($userId, $categoryId);

            $recommendations[] = [
                'category' => $data['category_name'],
                'recommended_budget' => $recommendedBudget,
                'current_budget' => $currentBudget,
                'suggestion' => 'Pertimbangkan anggaran sebesar Rp ' . number_format($recommendedBudget, 0, ',', '.'),
                'needs_adjustment' => $recommendedBudget != $currentBudget
            ];
        }

        // Save recommendations to database
        $this->saveBudgetRecommendationsToDatabase($userId, $recommendations);

        return $recommendations;
    }

    /**
     * Save budget recommendations to database
     */
    private function saveBudgetRecommendationsToDatabase(int $userId, array $recommendations)
    {
        // Delete old recommendations (older than 7 days)
        \App\Models\Models\FinancialRecommendation::where('user_id', $userId)
            ->where('type', 'budget_recommendation')
            ->where('created_at', '<', Carbon::now()->subDays(7))
            ->delete();

        foreach ($recommendations as $rec) {
            \App\Models\Models\FinancialRecommendation::create([
                'user_id' => $userId,
                'type' => 'budget_recommendation',
                'title' => 'Rekomendasi Anggaran untuk Kategori ' . $rec['category'],
                'description' => $rec['suggestion'],
                'data' => [
                    'category' => $rec['category'],
                    'recommended_budget' => $rec['recommended_budget'],
                    'current_budget' => $rec['current_budget'],
                    'needs_adjustment' => $rec['needs_adjustment']
                ],
                'priority' => $rec['needs_adjustment'] ? 'medium' : 'low'
            ]);
        }
    }

    /**
     * Get current budget for a category
     */
    private function getCurrentBudgetForCategory(int $userId, int $categoryId = null)
    {
        $currentMonth = Carbon::now()->format('Y-m');

        $budget = Budget::where('user_id', $userId)
            ->where('month', $currentMonth)
            ->where('category_id', $categoryId)
            ->first();

        return $budget ? $budget->amount : 0;
    }

    /**
     * Predict future financial status
     */
    public function predictFinancialStatus(int $userId)
    {
        $savingsProjection = $this->predictSavings($userId);
        $expenseProjection = $this->predictExpenses($userId);
        $budgetProjection = $this->predictBudgetAdherence($userId);

        $prediction = [
            'savings_projection' => $savingsProjection,
            'expense_projection' => $expenseProjection,
            'budget_projection' => $budgetProjection
        ];

        // Save predictions to database
        $this->savePredictionsToDatabase($userId, $savingsProjection, $expenseProjection, $budgetProjection);

        return $prediction;
    }

    /**
     * Save predictions to database
     */
    private function savePredictionsToDatabase(int $userId, array $savingsProjection, array $expenseProjection, array $budgetProjection)
    {
        // Delete old predictions (older than 7 days)
        \App\Models\Models\FinancialPrediction::where('user_id', $userId)
            ->where('generated_at', '<', Carbon::now()->subDays(7))
            ->delete();

        // Save savings projections
        foreach ($savingsProjection as $projection) {
            \App\Models\Models\FinancialPrediction::create([
                'user_id' => $userId,
                'type' => 'savings_projection',
                'data' => $projection,
                'period' => 'monthly',
                'prediction_date' => Carbon::now()->addMonth()->toDateString(),
                'confidence_level' => 85.00,
                'is_active' => true
            ]);
        }

        // Save expense projections
        \App\Models\Models\FinancialPrediction::create([
            'user_id' => $userId,
            'type' => 'expense_projection',
            'data' => $expenseProjection,
            'period' => 'monthly',
            'prediction_date' => Carbon::now()->addMonth()->toDateString(),
            'confidence_level' => 80.00,
            'is_active' => true
        ]);

        // Save budget projections
        foreach ($budgetProjection as $projection) {
            \App\Models\Models\FinancialPrediction::create([
                'user_id' => $userId,
                'type' => 'budget_projection',
                'data' => $projection,
                'period' => 'monthly',
                'prediction_date' => Carbon::now()->addMonth()->toDateString(),
                'confidence_level' => 82.00,
                'is_active' => true
            ]);
        }
    }

    /**
     * Predict savings based on current trend
     */
    private function predictSavings(int $userId)
    {
        $savingsGoals = SavingsGoal::where('user_id', $userId)
            ->where('status', 'active')
            ->get();

        $predictions = [];

        foreach ($savingsGoals as $goal) {
            $dailySavingsRate = $goal->current_amount / (Carbon::today()->diffInDays(Carbon::parse($goal->created_at)) + 1);
            $daysToTarget = Carbon::parse($goal->target_date)->diffInDays(Carbon::today());

            $projectedAmount = $goal->current_amount + ($dailySavingsRate * $daysToTarget);

            $predictions[] = [
                'goal_name' => $goal->name,
                'projected_amount' => $projectedAmount,
                'target_amount' => $goal->target_amount,
                'will_achieve' => $projectedAmount >= $goal->target_amount,
                'achievement_percentage' => min(100, round(($projectedAmount / $goal->target_amount) * 100, 2)),
                'daily_savings_needed' => $goal->target_amount > $goal->current_amount ? ($goal->target_amount - $goal->current_amount) / $daysToTarget : 0
            ];
        }

        return $predictions;
    }

    /**
     * Predict expenses based on historical data
     */
    private function predictExpenses(int $userId)
    {
        // Get average monthly expenses for the last 3 months
        $threeMonthsAgo = Carbon::now()->subMonths(3);

        $monthlyExpenses = [];
        for ($i = 2; $i >= 0; $i--) {
            $month = Carbon::now()->subMonths($i);
            $expenses = Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereMonth('date', $month->month)
                ->whereYear('date', $month->year)
                ->sum('amount');

            $monthlyExpenses[] = $expenses;
        }

        // Simple prediction: average of last 3 months
        $averageMonthlyExpense = count($monthlyExpenses) > 0 ? array_sum($monthlyExpenses) / count($monthlyExpenses) : 0;

        return [
            'predicted_monthly_expense' => $averageMonthlyExpense,
            'historical_expenses' => $monthlyExpenses,
            'trend' => $this->calculateExpenseTrend($monthlyExpenses)
        ];
    }

    /**
     * Calculate expense trend
     */
    private function calculateExpenseTrend(array $monthlyExpenses)
    {
        if (count($monthlyExpenses) < 2) {
            return 'unknown';
        }

        $recentExpense = end($monthlyExpenses);
        $previousExpense = prev($monthlyExpenses);

        if ($recentExpense > $previousExpense) {
            return 'increasing';
        } elseif ($recentExpense < $previousExpense) {
            return 'decreasing';
        } else {
            return 'stable';
        }
    }

    /**
     * Predict budget adherence
     */
    private function predictBudgetAdherence(int $userId)
    {
        $currentMonth = Carbon::now()->format('Y-m');

        $budgets = Budget::where('user_id', $userId)
            ->where('month', $currentMonth)
            ->get();

        $predictions = [];

        foreach ($budgets as $budget) {
            // Calculate daily spending rate
            $daysPassed = Carbon::today()->diffInDays(Carbon::now()->startOfMonth()) + 1;
            $dailySpendingRate = $budget->spent_amount / $daysPassed;

            // Predict end of month spending
            $daysInMonth = Carbon::now()->daysInMonth;
            $predictedEndOfMonthSpending = $dailySpendingRate * $daysInMonth;

            $predictions[] = [
                'category' => $budget->category ? $budget->category->name : 'Umum',
                'budget_amount' => $budget->amount,
                'predicted_spending' => $predictedEndOfMonthSpending,
                'will_exceed' => $predictedEndOfMonthSpending > $budget->amount,
                'excess_amount' => max(0, $predictedEndOfMonthSpending - $budget->amount),
                'remaining_budget' => max(0, $budget->amount - $budget->spent_amount),
                'days_remaining' => Carbon::now()->daysInMonth - Carbon::today()->day + 1
            ];
        }

        return $predictions;
    }

    /**
     * Generate financial health score
     */
    public function generateFinancialHealthScore(int $userId)
    {
        $score = 100; // Start with perfect score
        $factors = [];

        // Factor 1: Budget adherence (max 30 points deduction)
        $budgetAdherence = $this->analyzeBudgetAdherence($userId);
        if (!empty($budgetAdherence['over_budget_categories'])) {
            $deduction = min(30, count($budgetAdherence['over_budget_categories']) * 10);
            $score -= $deduction;
            $factors[] = [
                'factor' => 'Budget Adherence',
                'points_deducted' => $deduction,
                'details' => 'Melebihi anggaran di ' . count($budgetAdherence['over_budget_categories']) . ' kategori'
            ];
        }

        // Factor 2: Savings rate (max 25 points deduction)
        $savingsRate = $this->calculateSavingsRate($userId);
        if ($savingsRate < 0.1) { // Less than 10% of income
            $deduction = 25 - ($savingsRate * 250); // Scale deduction based on actual rate
            $score = max(0, $score - $deduction);
            $factors[] = [
                'factor' => 'Savings Rate',
                'points_deducted' => $deduction,
                'details' => 'Tingkat tabungan hanya ' . round($savingsRate * 100, 1) . '% dari pendapatan'
            ];
        }

        // Factor 3: Expense trend (max 20 points deduction)
        $expenseTrend = $this->predictExpenses($userId)['trend'];
        if ($expenseTrend === 'increasing') {
            $score -= 20;
            $factors[] = [
                'factor' => 'Expense Trend',
                'points_deducted' => 20,
                'details' => 'Pengeluaran meningkat dalam 3 bulan terakhir'
            ];
        } elseif ($expenseTrend === 'decreasing') {
            $score += 5; // Bonus for decreasing expenses
            $factors[] = [
                'factor' => 'Expense Trend',
                'points_added' => 5,
                'details' => 'Pengeluaran menurun dalam 3 bulan terakhir'
            ];
        }

        // Factor 4: Overdue bills (max 25 points deduction)
        $overdueBills = $this->analyzeUpcomingBills($userId)['overdue_count'];
        if ($overdueBills > 0) {
            $deduction = min(25, $overdueBills * 8);
            $score = max(0, $score - $deduction);
            $factors[] = [
                'factor' => 'Overdue Bills',
                'points_deducted' => $deduction,
                'details' => $overdueBills . ' tagihan terlambat'
            ];
        }

        $score = max(0, min(100, $score)); // Ensure score is between 0-100

        return [
            'score' => round($score),
            'grade' => $this->getGradeFromScore($score),
            'factors' => $factors,
            'recommendations' => $this->getRecommendationsFromScore($score)
        ];
    }

    /**
     * Calculate savings rate
     */
    private function calculateSavingsRate(int $userId)
    {
        $currentMonth = Carbon::now()->format('Y-m');

        $income = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereMonth('date', Carbon::now()->month)
            ->whereYear('date', Carbon::now()->year)
            ->sum('amount');

        $expenses = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereMonth('date', Carbon::now()->month)
            ->whereYear('date', Carbon::now()->year)
            ->sum('amount');

        $savings = $income - $expenses;

        return $income > 0 ? $savings / $income : 0;
    }

    /**
     * Get grade from score
     */
    private function getGradeFromScore(float $score)
    {
        if ($score >= 80) return 'Sangat Baik';
        if ($score >= 60) return 'Baik';
        if ($score >= 40) return 'Cukup';
        if ($score >= 20) return 'Kurang';
        return 'Buruk';
    }

    /**
     * Get recommendations based on score
     */
    private function getRecommendationsFromScore(float $score)
    {
        $recommendations = [];

        if ($score < 40) {
            $recommendations[] = 'Pertimbangkan untuk membuat anggaran bulanan yang ketat';
            $recommendations[] = 'Kurangi pengeluaran yang tidak perlu';
            $recommendations[] = 'Fokus pada pembayaran utang terlebih dahulu';
        } elseif ($score < 60) {
            $recommendations[] = 'Coba sisihkan 10-15% dari pendapatan untuk tabungan';
            $recommendations[] = 'Evaluasi kembali anggaran Anda setiap bulan';
        } elseif ($score < 80) {
            $recommendations[] = 'Pertahankan kebiasaan keuangan yang baik';
            $recommendations[] = 'Pertimbangkan untuk menambah dana darurat';
        } else {
            $recommendations[] = 'Luar biasa! Pertahankan kebiasaan keuangan yang baik';
            $recommendations[] = 'Pertimbangkan investasi untuk masa depan';
        }

        return $recommendations;
    }

    /**
     * Dapatkan semua rekomendasi keuangan untuk pengguna
     */
    public function getFinancialRecommendations(int $userId)
    {
        return \App\Models\Models\FinancialRecommendation::where('user_id', $userId)
            ->orderBy('priority', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Dapatkan rekomendasi anggaran untuk pengguna
     */
    public function getBudgetRecommendationsFromDB(int $userId)
    {
        return \App\Models\Models\FinancialRecommendation::where('user_id', $userId)
            ->where('type', 'budget_recommendation')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    /**
     * Tandai rekomendasi sebagai telah diterapkan
     */
    public function markRecommendationAsApplied(int $recommendationId, int $userId)
    {
        $recommendation = \App\Models\Models\FinancialRecommendation::where('id', $recommendationId)
            ->where('user_id', $userId)
            ->first();

        if ($recommendation) {
            $recommendation->update([
                'is_applied' => true,
                'applied_at' => Carbon::now()
            ]);
            return true;
        }

        return false;
    }
}