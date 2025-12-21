<?php

namespace App\Services;

use App\Models\RecurringExpense;
use App\Models\Transaction;
use App\Models\Category;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class RecurringExpenseService
{
    public function processRecurringExpenses()
    {
        // Get all recurring expenses that have auto_add enabled and need to be processed today or before
        $recurringExpenses = RecurringExpense::where('auto_add', true)
            ->where('next_run_date', '<=', Carbon::now()->toDateString())
            ->get();

        foreach ($recurringExpenses as $recurringExpense) {
            // Create a transaction for the recurring expense
            $transaction = Transaction::create([
                'user_id' => $recurringExpense->user_id,
                'amount' => $recurringExpense->amount,
                'type' => 'expense',
                'description' => 'Auto-generated: ' . $recurringExpense->name,
                'date' => Carbon::now()->toDateString(),
            ]);

            // Find or create a category for recurring expenses
            $category = Category::firstOrCreate(
                ['name' => 'Recurring Expense', 'type' => 'expense'],
                ['user_id' => $recurringExpense->user_id] // Using first user as default, or null for system default
            );

            $transaction->category_id = $category->id;
            $transaction->save();

            // Update the next run date based on the cycle
            $this->updateNextRunDate($recurringExpense);
        }
    }

    private function updateNextRunDate(RecurringExpense $recurringExpense)
    {
        $nextRunDate = Carbon::parse($recurringExpense->next_run_date);

        switch ($recurringExpense->cycle) {
            case 'daily':
                $nextRunDate->addDay();
                break;
            case 'weekly':
                $nextRunDate->addWeek();
                break;
            case 'monthly':
                $nextRunDate->addMonth();
                break;
            case 'yearly':
                $nextRunDate->addYear();
                break;
        }

        $recurringExpense->update([
            'next_run_date' => $nextRunDate->toDateString()
        ]);
    }
}