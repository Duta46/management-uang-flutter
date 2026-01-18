<?php

namespace App\Services;

use App\Models\Models\Budget;
use App\Models\SavingsGoal;
use App\Models\Models\BillReminder;
use App\Models\Transaction;
use App\Models\Category;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class FinancialReportService
{
    /**
     * Generate financial summary for a user
     */
    public function getFinancialSummary(int $userId, string $period = 'monthly')
    {
        $startDate = $this->getStartDate($period);
        $endDate = Carbon::today();

        // Total income and expenses
        $income = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereBetween('date', [$startDate, $endDate])
            ->sum('amount');

        $expenses = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('date', [$startDate, $endDate])
            ->sum('amount');

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
        ];
    }

    /**
     * Get expense breakdown by category
     */
    public function getExpenseBreakdown(int $userId, string $period = 'monthly')
    {
        $startDate = $this->getStartDate($period);
        $endDate = Carbon::today();

        $expenses = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('date', [$startDate, $endDate])
            ->with('category')
            ->get();

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
    public function getBudgetVsActual(int $userId, string $period = 'monthly')
    {
        $month = $this->getStartDate($period)->format('Y-m');

        $budgets = Budget::where('user_id', $userId)
            ->where('month', $month)
            ->with('category')
            ->get();

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
}