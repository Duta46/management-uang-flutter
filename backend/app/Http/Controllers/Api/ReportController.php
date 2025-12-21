<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\TransactionServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    private TransactionServiceInterface $transactionService;

    public function __construct(TransactionServiceInterface $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function daily(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $date = $request->get('date', date('Y-m-d'));
        
        $transactions = $this->transactionService->getAllTransactions($userId, [
            'start_date' => $date,
            'end_date' => $date
        ]);

        return response()->json([
            'success' => true,
            'data' => $transactions,
            'message' => 'Daily report retrieved successfully'
        ]);
    }

    public function monthly(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $month = $request->get('month', date('n')); // Current month if not provided
        $year = $request->get('year', date('Y'));  // Current year if not provided

        $transactions = $this->transactionService->getAllTransactions($userId, [
            'start_date' => "$year-$month-01",
            'end_date' => date("Y-m-t", mktime(0, 0, 0, $month, 1, $year))
        ]);

        $summary = $this->transactionService->getMonthlySummary($userId, $month, $year);

        return response()->json([
            'success' => true,
            'data' => [
                'transactions' => $transactions,
                'summary' => $summary
            ],
            'message' => 'Monthly report retrieved successfully'
        ]);
    }
}