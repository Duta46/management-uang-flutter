<?php

namespace App\Services;

use App\Models\Budget;
use App\Models\SavingsGoal;
use App\Models\BillReminder;
use App\Models\Transaction;
use App\Models\Category;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class FinancialReportService
{
    /**
     * Generate financial summary for a user
     */
    public function getFinancialSummary(int $userId, string $period = 'monthly', ?int $year = null, ?int $month = null)
    {
        \Log::info('getFinancialSummary called', [
            'userId' => $userId,
            'period' => $period,
            'year' => $year,
            'month' => $month
        ]);

        try {
            // Jika tahun dan bulan disediakan, kita prioritaskan itu daripada period
            if ($this->validateMonthYear($year, $month)) {
                $startDate = Carbon::createFromDate($year, $month, 1);
                $endDate = $startDate->copy()->endOfMonth();

                \Log::info('Using specific month/year filter', [
                    'startDate' => $startDate->format('Y-m-d'),
                    'endDate' => $endDate->format('Y-m-d')
                ]);
            } else {
                $startDate = $this->getStartDate($period);
                $endDate = Carbon::today();

                \Log::info('Using period filter', [
                    'startDate' => $startDate->format('Y-m-d'),
                    'endDate' => $endDate->format('Y-m-d')
                ]);
            }

            // Total income and expenses
            $incomeQuery = Transaction::where('user_id', $userId)
                ->where('type', 'income')
                ->whereDate('date', '>=', $startDate->format('Y-m-d'))
                ->whereDate('date', '<=', $endDate->format('Y-m-d'));

            // Ambil semua transaksi untuk debugging
            $incomeTransactions = $incomeQuery->get();
            $income = $incomeTransactions->sum(function($transaction) {
                return (float) $transaction->amount;
            });

            \Log::info('Income query result', [
                'income' => $income,
                'count' => $incomeQuery->count(),
                'raw_transactions' => $incomeTransactions->pluck('amount')->toArray(),
                'query' => $incomeQuery->toSql(),
                'bindings' => $incomeQuery->getBindings(),
                'startDate_formatted' => $startDate->format('Y-m-d'),
                'endDate_formatted' => $endDate->format('Y-m-d')
            ]);

            $expensesQuery = Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereDate('date', '>=', $startDate->format('Y-m-d'))
                ->whereDate('date', '<=', $endDate->format('Y-m-d'));

            // Ambil semua transaksi untuk debugging
            $expenseTransactions = $expensesQuery->get();
            $expenses = $expenseTransactions->sum(function($transaction) {
                return (float) $transaction->amount;
            });

            \Log::info('Expenses query result', [
                'expenses' => $expenses,
                'count' => $expensesQuery->count(),
                'raw_transactions' => $expenseTransactions->pluck('amount')->toArray(),
                'query' => $expensesQuery->toSql(),
                'bindings' => $expensesQuery->getBindings(),
                'startDate_formatted' => $startDate->format('Y-m-d'),
                'endDate_formatted' => $endDate->format('Y-m-d')
            ]);
        } catch (\Exception $e) {
            \Log::error('Error in getFinancialSummary', [
                'error' => $e->getMessage(),
                'userId' => $userId,
                'period' => $period,
                'year' => $year,
                'month' => $month
            ]);
            throw $e;
        }

        // Budget summary
        $budgets = Budget::where('user_id', $userId)
            ->where('month', $startDate->format('Y-m'))
            ->get();

        $totalBudgeted = $budgets->sum('amount');
        $totalSpent = $budgets->sum('spent_amount');

        // Savings goals progress
        $savingsGoals = SavingsGoal::where('user_id', $userId)
            ->where('status', 'active')
            ->get();

        $totalSavingsTarget = $savingsGoals->sum('target_amount');
        $totalSavingsCurrent = $savingsGoals->sum('current_amount');

        // Bill reminders
        $dueBills = BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->where('due_date', '<=', $endDate)
            ->sum('amount');

        $upcomingBills = BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->where('due_date', '>', $endDate)
            ->where('due_date', '<=', $endDate->copy()->addDays(30))
            ->sum('amount');

        // Jika kita menggunakan filter bulan dan tahun spesifik, ambil juga transaksi untuk laporan
        $transactions = [];
        try {
            if ($this->validateMonthYear($year, $month)) {
                // Ambil transaksi untuk bulan dan tahun yang ditentukan
                $transactionService = app(TransactionServiceInterface::class);
                $transactions = $transactionService->getMonthlyTransactions($userId, $month, $year);
            } else {
                // Ambil transaksi untuk periode yang ditentukan
                $transactions = Transaction::where('user_id', $userId)
                    ->whereBetween('date', [$startDate, $endDate])
                    ->with('category')
                    ->orderBy('date', 'desc')
                    ->get()
                    ->toArray();
            }
        } catch (\Exception $e) {
            \Log::error('Error getting transactions for report', [
                'error' => $e->getMessage(),
                'userId' => $userId,
                'year' => $year,
                'month' => $month
            ]);
            $transactions = [];
        }

        return [
            'period' => $period,
            'start_date' => $startDate->format('Y-m-d'),
            'end_date' => $endDate->format('Y-m-d'),
            'income' => $income,
            'expenses' => $expenses,
            'net_income' => $income - $expenses,
            'total_budgeted' => $totalBudgeted,
            'total_spent' => $totalSpent,
            'budget_remaining' => $totalBudgeted - $totalSpent,
            'total_savings_target' => $totalSavingsTarget,
            'total_savings_current' => $totalSavingsCurrent,
            'savings_progress' => $totalSavingsTarget > 0 ? round(($totalSavingsCurrent / $totalSavingsTarget) * 100, 2) : 0,
            'due_bills' => $dueBills,
            'upcoming_bills' => $upcomingBills,
            'transactions' => $transactions,
            'debug_info' => [
                'income_raw' => $income,
                'expenses_raw' => $expenses,
                'income_count' => $incomeTransactions->count(),
                'expenses_count' => $expenseTransactions->count(),
                'start_date_used' => $startDate->format('Y-m-d'),
                'end_date_used' => $endDate->format('Y-m-d'),
            ],
        ];
    }

    /**
     * Get expense breakdown by category
     */
    public function getExpenseBreakdown(int $userId, string $period = 'monthly', ?int $year = null, ?int $month = null)
    {
        try {
            // Jika tahun dan bulan disediakan, kita prioritaskan itu daripada period
            if ($this->validateMonthYear($year, $month)) {
                $startDate = Carbon::createFromDate($year, $month, 1);
                $endDate = $startDate->copy()->endOfMonth();
            } else {
                $startDate = $this->getStartDate($period);
                $endDate = Carbon::today();
            }

            $expenses = Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereBetween('date', [$startDate, $endDate])
                ->with('category')
                ->get();
        } catch (\Exception $e) {
            \Log::error('Error in getExpenseBreakdown', [
                'error' => $e->getMessage(),
                'userId' => $userId,
                'period' => $period,
                'year' => $year,
                'month' => $month
            ]);
            throw $e;
        }

        $categoryBreakdown = [];
        $totalExpenses = $expenses->sum('amount');

        foreach ($expenses as $transaction) {
            $categoryName = $transaction->category ? $transaction->category->name : 'Uncategorized';
            
            if (!isset($categoryBreakdown[$categoryName])) {
                $categoryBreakdown[$categoryName] = [
                    'amount' => 0,
                    'percentage' => 0
                ];
            }
            
            $categoryBreakdown[$categoryName]['amount'] += $transaction->amount;
        }

        // Calculate percentages
        foreach ($categoryBreakdown as $category => $data) {
            $categoryBreakdown[$category]['percentage'] = $totalExpenses > 0 
                ? round(($data['amount'] / $totalExpenses) * 100, 2) 
                : 0;
        }

        return [
            'total_expenses' => $totalExpenses,
            'breakdown' => $categoryBreakdown
        ];
    }

    /**
     * Get budget vs actual spending comparison
     */
    public function getBudgetVsActual(int $userId, string $period = 'monthly', ?int $year = null, ?int $month = null)
    {
        try {
            // Jika tahun dan bulan disediakan, kita prioritaskan itu daripada period
            if ($this->validateMonthYear($year, $month)) {
                $monthStr = sprintf('%04d-%02d', $year, $month);
            } else {
                $monthStr = $this->getStartDate($period)->format('Y-m');
            }

            $budgets = Budget::where('user_id', $userId)
                ->where('month', $monthStr)
                ->with('category')
                ->get();
        } catch (\Exception $e) {
            \Log::error('Error in getBudgetVsActual', [
                'error' => $e->getMessage(),
                'userId' => $userId,
                'period' => $period,
                'year' => $year,
                'month' => $month
            ]);
            throw $e;
        }

        $results = [];

        foreach ($budgets as $budget) {
            $categoryName = $budget->category ? $budget->category->name : 'Uncategorized';
            
            $results[] = [
                'category' => $categoryName,
                'budgeted' => $budget->amount,
                'spent' => $budget->spent_amount,
                'remaining' => $budget->amount - $budget->spent_amount,
                'overspent' => max(0, $budget->spent_amount - $budget->amount),
                'percentage_used' => $budget->amount > 0 
                    ? round(($budget->spent_amount / $budget->amount) * 100, 2) 
                    : 0
            ];
        }

        return $results;
    }

    /**
     * Get savings goals progress
     */
    public function getSavingsGoalsProgress(int $userId)
    {
        $savingsGoals = SavingsGoal::where('user_id', $userId)->get();

        $results = [];

        foreach ($savingsGoals as $goal) {
            $results[] = [
                'name' => $goal->name,
                'target_amount' => $goal->target_amount,
                'current_amount' => $goal->current_amount,
                'progress_percentage' => $goal->target_amount > 0 
                    ? round(($goal->current_amount / $goal->target_amount) * 100, 2) 
                    : 0,
                'target_date' => $goal->target_date,
                'days_remaining' => Carbon::today()->diffInDays($goal->target_date, false),
                'status' => $goal->status
            ];
        }

        return $results;
    }

    /**
     * Get upcoming bills
     */
    public function getUpcomingBills(int $userId, int $days = 30)
    {
        $endDate = Carbon::today()->addDays($days);

        $bills = BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->where('due_date', '<=', $endDate)
            ->orderBy('due_date', 'asc')
            ->get();

        $results = [];

        foreach ($bills as $bill) {
            $results[] = [
                'name' => $bill->name,
                'amount' => $bill->amount,
                'due_date' => $bill->due_date,
                'days_until_due' => Carbon::today()->diffInDays($bill->due_date, false),
                'frequency' => $bill->frequency,
                'status' => $bill->is_paid ? 'paid' : 'unpaid'
            ];
        }

        return $results;
    }

    /**
     * Helper to get start date based on period
     */
    private function getStartDate(string $period): Carbon
    {
        $today = Carbon::today();

        switch ($period) {
            case 'daily':
                return $today;
            case 'weekly':
                return $today->copy()->startOfWeek();
            case 'monthly':
                return $today->copy()->startOfMonth();
            case 'yearly':
                return $today->copy()->startOfYear();
            default:
                return $today->copy()->startOfMonth();
        }
    }

    /**
     * Helper to validate month and year parameters
     */
    private function validateMonthYear(?int $year, ?int $month): bool
    {
        if ($year === null || $month === null) {
            return false;
        }

        // Check if month is between 1 and 12
        if ($month < 1 || $month > 12) {
            return false;
        }

        // Check if year is reasonable (between 1900 and 2100)
        if ($year < 1900 || $year > 2100) {
            return false;
        }

        return true;
    }
}