<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Budget;
use App\Services\BudgetService;
use App\Repositories\BudgetRepositoryInterface;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class BudgetController extends Controller
{
    protected BudgetService $budgetService;
    protected BudgetRepositoryInterface $budgetRepository;

    public function __construct(BudgetService $budgetService, BudgetRepositoryInterface $budgetRepository)
    {
        $this->budgetService = $budgetService;
        $this->budgetRepository = $budgetRepository;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $filters = [
                'per_page' => $request->get('per_page', 15)
            ];

            $budgets = $this->budgetRepository->getAll($user->id, $filters);

            // Tambahkan status dan progress ke setiap budget
            foreach ($budgets as $budget) {
                $budget->status = $this->budgetService->getBudgetStatus($budget);
                $budget->remaining_amount = $budget->amount - $budget->spent_amount;
                $budget->progress_percentage = $budget->amount > 0 ? round(($budget->spent_amount / $budget->amount) * 100, 2) : 0;
            }

            return response()->json([
                'success' => true,
                'data' => $budgets,
                'message' => 'Budgets retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving budgets: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'category_id' => 'nullable|exists:categories,id',
                'amount' => 'required|numeric|min:0.01',
                'month' => 'required|date_format:Y-m',
                'name' => 'required|string|max:255',
                'description' => 'nullable|string'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            // Cek apakah sudah ada anggaran untuk kategori dan bulan yang sama
            $existingBudget = $this->budgetRepository->getByUserIdAndMonth($user->id, $request->month)
                ->where('category_id', $request->category_id)
                ->first();

            if ($existingBudget) {
                return response()->json([
                    'success' => false,
                    'message' => 'Budget for this category and month already exists'
                ], 409);
            }

            $data = [
                'user_id' => $user->id,
                'category_id' => $request->category_id,
                'amount' => $request->amount,
                'spent_amount' => 0, // Awalnya belum ada pengeluaran
                'month' => $request->month,
                'name' => $request->name,
                'description' => $request->description
            ];

            $budget = $this->budgetRepository->create($data);

            // Update spent amount berdasarkan transaksi yang sudah ada
            $budget = $this->budgetService->updateBudgetSpentAmount($budget);

            return response()->json([
                'success' => true,
                'data' => $budget->load('category'),
                'message' => 'Budget created successfully'
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while creating budget: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id, Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $budget = $this->budgetRepository->getById($id, $user->id);

            if (!$budget) {
                return response()->json([
                    'success' => false,
                    'message' => 'Budget not found'
                ], 404);
            }

            // Tambahkan status dan progress ke budget
            $budget->status = $this->budgetService->getBudgetStatus($budget);
            $budget->remaining_amount = $budget->amount - $budget->spent_amount;
            $budget->progress_percentage = $budget->amount > 0 ? round(($budget->spent_amount / $budget->amount) * 100, 2) : 0;

            return response()->json([
                'success' => true,
                'data' => $budget,
                'message' => 'Budget retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving budget: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'category_id' => 'sometimes|nullable|exists:categories,id',
                'amount' => 'sometimes|numeric|min:0.01',
                'month' => 'sometimes|date_format:Y-m',
                'name' => 'sometimes|string|max:255',
                'description' => 'sometimes|nullable|string'
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $budget = $this->budgetRepository->getById($id, $user->id);

            if (!$budget) {
                return response()->json([
                    'success' => false,
                    'message' => 'Budget not found'
                ], 404);
            }

            $data = $request->only(['category_id', 'amount', 'month', 'name', 'description']);
            $budget = $this->budgetRepository->update($id, $user->id, $data);

            // Update spent amount berdasarkan transaksi yang sudah ada
            $budget = $this->budgetService->updateBudgetSpentAmount($budget);

            return response()->json([
                'success' => true,
                'data' => $budget->load('category'),
                'message' => 'Budget updated successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while updating budget: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id, Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $result = $this->budgetRepository->delete($id, $user->id);

            if (!$result) {
                return response()->json([
                    'success' => false,
                    'message' => 'Budget not found'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Budget deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while deleting budget: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get budgets with status and progress
     */
    public function getBudgetsWithStatus(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $budgets = $this->budgetService->getBudgetsWithStatus($user->id);

            return response()->json([
                'success' => true,
                'data' => $budgets,
                'message' => 'Budgets with status retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving budgets with status: ' . $e->getMessage()
            ], 500);
        }
    }
}
