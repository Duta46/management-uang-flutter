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
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $userId = $user->id;
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
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving daily report: ' . $e->getMessage()
            ], 500);
        }
    }

    public function monthly(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $userId = $user->id;
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
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving monthly report: ' . $e->getMessage()
            ], 500);
        }
    }
}