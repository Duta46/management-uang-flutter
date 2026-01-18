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
        try {
            \Log::info('Creating transaction', ['user_id' => auth()->id(), 'request_data' => $request->all()]);

            $userId = auth()->id();

            $request->validate([
                'category_id' => 'nullable|integer',
                'bill_reminder_id' => 'nullable|integer',
                'savings_goal_id' => 'nullable|integer',
                'amount' => 'required|numeric|min:0.01',
                'type' => 'required|in:income,expense',
                'description' => 'nullable|string|max:255',
                'date' => 'required|date',
            ]);

            // Validasi bahwa category_id milik pengguna (jika disediakan dan bukan null)
            if ($request->has('category_id') && $request->category_id !== null) {
                $category = \App\Models\Category::where('id', $request->category_id)
                    ->where('user_id', $userId)
                    ->first();

                if (!$category) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Category does not belong to user'
                    ], 400);
                }
            }

            // Validasi bahwa bill_reminder_id milik pengguna (jika disediakan dan bukan null)
            if ($request->has('bill_reminder_id') && $request->bill_reminder_id !== null) {
                $billReminder = \App\Models\BillReminder::where('id', $request->bill_reminder_id)
                    ->where('user_id', $userId)
                    ->first();

                if (!$billReminder) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Bill reminder does not belong to user'
                    ], 400);
                }
            }

            // Validasi bahwa savings_goal_id milik pengguna (jika disediakan dan bukan null)
            if ($request->has('savings_goal_id') && $request->savings_goal_id !== null) {
                $savingsGoal = \App\Models\SavingsGoal::where('id', $request->savings_goal_id)
                    ->where('user_id', $userId)
                    ->first();

                if (!$savingsGoal) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Savings goal does not belong to user'
                    ], 400);
                }
            }

            $data = $request->all();
            $data['user_id'] = $userId;

            $transaction = $this->transactionService->createTransaction($data);

            \Log::info('Transaction created successfully', ['transaction_id' => $transaction->id]);

            return response()->json([
                'success' => true,
                'data' => $transaction,
                'message' => 'Transaction created successfully'
            ], 201);
        } catch (\Exception $e) {
            \Log::error('Error creating transaction', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while creating transaction: ' . $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $userId = auth()->id();

        $request->validate([
            'category_id' => 'sometimes|nullable|integer',
            'bill_reminder_id' => 'sometimes|nullable|integer',
            'savings_goal_id' => 'sometimes|nullable|integer',
            'amount' => 'sometimes|numeric|min:0.01',
            'type' => 'sometimes|in:income,expense',
            'description' => 'nullable|string|max:255',
            'date' => 'sometimes|date',
        ]);

        // Validasi bahwa category_id milik pengguna (jika disediakan dan bukan null)
        if ($request->has('category_id') && $request->category_id !== null) {
            $category = \App\Models\Category::where('id', $request->category_id)
                ->where('user_id', $userId)
                ->first();

            if (!$category) {
                return response()->json([
                    'success' => false,
                    'message' => 'Category does not belong to user'
                ], 400);
            }
        }

        // Validasi bahwa bill_reminder_id milik pengguna (jika disediakan dan bukan null)
        if ($request->has('bill_reminder_id') && $request->bill_reminder_id !== null) {
            $billReminder = \App\Models\BillReminder::where('id', $request->bill_reminder_id)
                ->where('user_id', $userId)
                ->first();

            if (!$billReminder) {
                return response()->json([
                    'success' => false,
                    'message' => 'Bill reminder does not belong to user'
                ], 400);
            }
        }

        // Validasi bahwa savings_goal_id milik pengguna (jika disediakan dan bukan null)
        if ($request->has('savings_goal_id') && $request->savings_goal_id !== null) {
            $savingsGoal = \App\Models\SavingsGoal::where('id', $request->savings_goal_id)
                ->where('user_id', $userId)
                ->first();

            if (!$savingsGoal) {
                return response()->json([
                    'success' => false,
                    'message' => 'Savings goal does not belong to user'
                ], 400);
            }
        }

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