<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\SavingsGoal;
use App\Services\SavingsGoalService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class SavingsGoalController extends Controller
{
    protected SavingsGoalService $savingsGoalService;

    public function __construct(SavingsGoalService $savingsGoalService)
    {
        $this->savingsGoalService = $savingsGoalService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            \Log::info('Fetching savings goals', ['user_id' => $request->user()?->id]);

            $user = $request->user();
            if (!$user) {
                \Log::error('User not authenticated for savings goals retrieval');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $savingsGoals = SavingsGoal::where('user_id', $user->id)
                ->orderBy('target_date', 'asc')
                ->orderBy('created_at', 'desc')
                ->paginate(15);

            // Tidak perlu menambahkan status dan progress karena sudah ada di model sebagai accessor
            // Progress, amount_needed, days_remaining, dan status_text sudah dihitung otomatis oleh accessor

            \Log::info('Savings goals retrieved successfully', ['count' => $savingsGoals->count()]);

            return response()->json([
                'success' => true,
                'data' => $savingsGoals,
                'message' => 'Savings goals retrieved successfully'
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in savings goals retrieval', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving savings goals: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        try {
            \Log::info('Creating savings goal', ['request_data' => $request->all()]);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'description' => 'nullable|string',
                'target_amount' => 'required|numeric|min:0.01',
                'target_date' => 'required|date|after_or_equal:today',
                'current_amount' => 'sometimes|numeric|min:0',
                'status' => 'in:active,achieved,cancelled'
            ]);

            if ($validator->fails()) {
                \Log::error('Validation failed for savings goal creation', ['errors' => $validator->errors()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            if (!$user) {
                \Log::error('User not authenticated for savings goal creation');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $savingsGoal = SavingsGoal::create([
                'user_id' => $user->id,
                'name' => $request->name,
                'description' => $request->description,
                'target_amount' => $request->target_amount,
                'current_amount' => $request->current_amount ?? 0,
                'target_date' => $request->target_date,
                'status' => $request->status ?? 'active'
            ]);

            if (!$savingsGoal) {
                \Log::error('Failed to create savings goal in database');
                return response()->json([
                    'success' => false,
                    'message' => 'Failed to create savings goal in database'
                ], 500);
            }

            // Tidak perlu menambahkan status dan progress karena sudah ada di model sebagai accessor
            // Progress, amount_needed, days_remaining, dan status_text sudah dihitung otomatis oleh accessor

            \Log::info('Savings goal created successfully', ['savings_goal_id' => $savingsGoal->id]);

            return response()->json([
                'success' => true,
                'data' => $savingsGoal,
                'message' => 'Savings goal created successfully'
            ], 201);
        } catch (\Exception $e) {
            \Log::error('Exception in savings goal creation', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while creating savings goal: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id, Request $request): JsonResponse
    {
        try {
            \Log::info('Fetching specific savings goal', ['id' => $id, 'user_id' => $request->user()?->id]);

            $user = $request->user();

            $savingsGoal = SavingsGoal::where('user_id', $user->id)->find($id);

            if (!$savingsGoal) {
                \Log::error('Savings goal not found for show', ['id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'Savings goal not found'
                ], 404);
            }

            // Tidak perlu menambahkan status dan progress karena sudah ada di model sebagai accessor
            // Progress, amount_needed, days_remaining, dan status_text sudah dihitung otomatis oleh accessor

            \Log::info('Savings goal retrieved successfully', ['id' => $id]);

            return response()->json([
                'success' => true,
                'data' => $savingsGoal,
                'message' => 'Savings goal retrieved successfully'
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in savings goal show', ['id' => $id, 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving savings goal: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        try {
            \Log::info('Updating savings goal', ['id' => $id, 'request_data' => $request->all()]);

            $validator = Validator::make($request->all(), [
                'name' => 'sometimes|string|max:255',
                'description' => 'nullable|string',
                'target_amount' => 'sometimes|numeric|min:0.01',
                'target_date' => 'sometimes|date|after_or_equal:today',
                'current_amount' => 'sometimes|numeric|min:0',
                'status' => 'in:active,achieved,cancelled'
            ]);

            if ($validator->fails()) {
                \Log::error('Validation failed for savings goal update', ['id' => $id, 'errors' => $validator->errors()]);
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $user = $request->user();
            if (!$user) {
                \Log::error('User not authenticated for savings goal update', ['id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $savingsGoal = SavingsGoal::where('user_id', $user->id)->find($id);

            if (!$savingsGoal) {
                \Log::error('Savings goal not found for update', ['id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'Savings goal not found'
                ], 404);
            }

            $savingsGoal->update($request->all());

            // Tidak perlu menambahkan status dan progress karena sudah ada di model sebagai accessor
            // Progress, amount_needed, days_remaining, dan status_text sudah dihitung otomatis oleh accessor

            \Log::info('Savings goal updated successfully', ['id' => $id]);

            return response()->json([
                'success' => true,
                'data' => $savingsGoal,
                'message' => 'Savings goal updated successfully'
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in savings goal update', ['id' => $id, 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while updating savings goal: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id, Request $request): JsonResponse
    {
        try {
            \Log::info('Deleting savings goal', ['id' => $id, 'user_id' => $request->user()?->id]);

            $user = $request->user();
            if (!$user) {
                \Log::error('User not authenticated for savings goal deletion', ['id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $savingsGoal = SavingsGoal::where('user_id', $user->id)->find($id);

            if (!$savingsGoal) {
                \Log::error('Savings goal not found for deletion', ['id' => $id]);
                return response()->json([
                    'success' => false,
                    'message' => 'Savings goal not found'
                ], 404);
            }

            $savingsGoal->delete();

            \Log::info('Savings goal deleted successfully', ['id' => $id]);

            return response()->json([
                'success' => true,
                'message' => 'Savings goal deleted successfully'
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in savings goal deletion', ['id' => $id, 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while deleting savings goal: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get savings goals with status and progress
     */
    public function getSavingsGoalsWithStatus(Request $request): JsonResponse
    {
        try {
            \Log::info('Fetching savings goals with status', ['user_id' => $request->user()?->id]);

            $user = $request->user();

            $savingsGoals = $this->savingsGoalService->getSavingsGoalsWithStatus($user->id);

            \Log::info('Savings goals with status retrieved successfully', ['count' => count($savingsGoals)]);

            return response()->json([
                'success' => true,
                'data' => $savingsGoals,
                'message' => 'Savings goals with status retrieved successfully'
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in savings goals with status retrieval', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving savings goals with status: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get active savings goals (not achieved) for use in transactions
     */
    public function getActiveSavingsGoals(Request $request): JsonResponse
    {
        try {
            \Log::info('Fetching active savings goals', ['user_id' => $request->user()?->id]);

            $user = $request->user();
            if (!$user) {
                \Log::error('User not authenticated for active savings goals retrieval');
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $savingsGoals = SavingsGoal::where('user_id', $user->id)
                ->where('status', '!=', 'achieved') // Hanya tampilkan yang belum tercapai
                ->orderBy('target_date', 'asc')
                ->orderBy('created_at', 'desc')
                ->get();

            \Log::info('Active savings goals retrieved successfully', ['count' => $savingsGoals->count()]);

            return response()->json([
                'success' => true,
                'data' => $savingsGoals,
                'message' => 'Active savings goals retrieved successfully'
            ]);
        } catch (\Exception $e) {
            \Log::error('Exception in active savings goals retrieval', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving active savings goals: ' . $e->getMessage()
            ], 500);
        }
    }
}
