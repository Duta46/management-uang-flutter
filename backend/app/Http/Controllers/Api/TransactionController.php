<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
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

    public function store(Request $request): JsonResponse
    {
        $userId = auth()->id();
        
        $request->validate([
            'category_id' => 'required|exists:categories,id',
            'amount' => 'required|numeric|min:0.01',
            'type' => 'required|in:income,expense',
            'description' => 'nullable|string|max:255',
            'date' => 'required|date',
        ]);

        $data = $request->all();
        $data['user_id'] = $userId;

        $transaction = $this->transactionService->createTransaction($data);

        return response()->json([
            'success' => true,
            'data' => $transaction,
            'message' => 'Transaction created successfully'
        ], 201);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $userId = auth()->id();
        
        $request->validate([
            'category_id' => 'sometimes|exists:categories,id',
            'amount' => 'sometimes|numeric|min:0.01',
            'type' => 'sometimes|in:income,expense',
            'description' => 'nullable|string|max:255',
            'date' => 'sometimes|date',
        ]);

        $transaction = $this->transactionService->updateTransaction($id, $userId, $request->all());

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
}