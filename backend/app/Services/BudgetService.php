<?php

namespace App\Services;

use App\Models\Budget;
use App\Models\Transaction;
use App\Repositories\BudgetRepositoryInterface;
use Illuminate\Support\Facades\DB;

class BudgetService
{
    private BudgetRepositoryInterface $budgetRepository;

    public function __construct(BudgetRepositoryInterface $budgetRepository)
    {
        $this->budgetRepository = $budgetRepository;
    }

    /**
     * Update spent amount when a transaction is created, updated, or deleted
     */
    public function updateBudgetSpentAmount(Budget $budget): Budget
    {
        // Hitung total pengeluaran untuk kategori dan bulan ini
        $totalSpent = Transaction::where('user_id', $budget->user_id)
            ->where('category_id', $budget->category_id)
            ->where('type', 'expense')
            ->whereMonth('date', $budget->month)
            ->whereYear('date', substr($budget->month, 0, 4))
            ->sum('amount');

        $budget->update(['spent_amount' => $totalSpent]);

        return $budget;
    }

    /**
     * Get budget status (on track, over budget, etc.)
     */
    public function getBudgetStatus(Budget $budget): string
    {
        if ($budget->amount == 0) {
            return 'no_budget';
        }

        $percentage = ($budget->spent_amount / $budget->amount) * 100;

        if ($percentage >= 100) {
            return 'over_budget';
        } elseif ($percentage >= 80) {
            return 'near_budget';
        } else {
            return 'on_track';
        }
    }

    /**
     * Get all budgets with their status and progress
     */
    public function getBudgetsWithStatus(int $userId)
    {
        $budgets = $this->budgetRepository->getByUserId($userId); // Perlu menambahkan method ini ke interface

        foreach ($budgets as $budget) {
            $budget->status = $this->getBudgetStatus($budget);
            $budget->remaining_amount = $budget->amount - $budget->spent_amount;
            $budget->progress_percentage = $budget->amount > 0 ? round(($budget->spent_amount / $budget->amount) * 100, 2) : 0;
        }

        return $budgets;
    }
}