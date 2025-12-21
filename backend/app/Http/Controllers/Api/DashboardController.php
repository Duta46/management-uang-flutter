<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TransactionServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    private TransactionServiceInterface $transactionService;

    public function __construct(TransactionServiceInterface $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function summary(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $month = $request->get('month', date('n')); // Current month if not provided
        $year = $request->get('year', date('Y'));  // Current year if not provided

        $summary = $this->transactionService->getMonthlySummary($userId, $month, $year);

        return response()->json([
            'success' => true,
            'data' => [
                'month' => $month,
                'year' => $year,
                'income' => $summary['income'],
                'expense' => $summary['expense'],
                'balance' => $summary['balance']
            ],
            'message' => 'Dashboard summary retrieved successfully'
        ]);
    }

    public function chart(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $month = $request->get('month', date('n')); // Current month if not provided
        $year = $request->get('year', date('Y'));  // Current year if not provided

        // Get transactions for the specified month
        $transactions = $this->transactionService->getAllTransactions($userId, [
            'start_date' => "$year-$month-01",
            'end_date' => date("Y-m-t", mktime(0, 0, 0, $month, 1, $year))
        ]);

        // Group transactions by category for chart
        $incomeByCategory = [];
        $expenseByCategory = [];

        foreach ($transactions as $transaction) {
            $categoryName = $transaction->category->name;
            $amount = $transaction->amount;

            if ($transaction->type === 'income') {
                $incomeByCategory[$categoryName] = ($incomeByCategory[$categoryName] ?? 0) + $amount;
            } else {
                $expenseByCategory[$categoryName] = ($expenseByCategory[$categoryName] ?? 0) + $amount;
            }
        }

        return response()->json([
            'success' => true,
            'data' => [
                'income_by_category' => $incomeByCategory,
                'expense_by_category' => $expenseByCategory,
            ],
            'message' => 'Dashboard chart data retrieved successfully'
        ]);
    }
}