<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Services\TransactionServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class TransactionController extends Controller
{
    private TransactionServiceInterface $transactionService;

    public function __construct(TransactionServiceInterface $transactionService)
    {
        $this->transactionService = $transactionService;
    }

    public function index(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $filters = [
            'type' => $request->get('type'),
            'start_date' => $request->get('start_date'),
            'end_date' => $request->get('end_date'),
            'category_id' => $request->get('category_id'),
            'per_page' => $request->get('per_page', 15)
        ];

        $transactions = $this->transactionService->getAllTransactions($userId, $filters);

        return response()->json([
            'success' => true,
            'data' => $transactions,
            'message' => 'Transactions retrieved successfully'
        ]);
    }

    public function show(int $id): JsonResponse
    {
        $userId = auth()->id();
        $transaction = $this->transactionService->getTransaction($id, $userId);

        if (!$transaction) {
            return response()->json([
                'success' => false,
                'message' => 'Transaction not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $transaction,
            'message' => 'Transaction retrieved successfully'
        ]);
    }

    public function store(StoreTransactionRequest $request): JsonResponse
    {
        $userId = auth()->id();
        $data = $request->validated();
        $data['user_id'] = $userId;

        $transaction = $this->transactionService->createTransaction($data);

        return response()->json([
            'success' => true,
            'data' => $transaction,
            'message' => 'Transaction created successfully'
        ], 201);
    }

    public function update(UpdateTransactionRequest $request, int $id): JsonResponse
    {
        $userId = auth()->id();
        $data = $request->validated();

        $transaction = $this->transactionService->updateTransaction($id, $userId, $data);

        if (!$transaction) {
            return response()->json([
                'success' => false,
                'message' => 'Transaction not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $transaction,
            'message' => 'Transaction updated successfully'
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $userId = auth()->id();
        $deleted = $this->transactionService->deleteTransaction($id, $userId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Transaction not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Transaction deleted successfully'
        ]);
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
            'message' => 'Monthly summary retrieved successfully'
        ]);
    }
}