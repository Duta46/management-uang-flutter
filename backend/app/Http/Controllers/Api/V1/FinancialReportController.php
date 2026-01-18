<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\FinancialReportService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class FinancialReportController extends Controller
{
    protected FinancialReportService $financialReportService;

    public function __construct(FinancialReportService $financialReportService)
    {
        $this->financialReportService = $financialReportService;
    }

    /**
     * Get financial summary
     */
    public function getFinancialSummary(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $period = $request->get('period', 'monthly');

            $summary = $this->financialReportService->getFinancialSummary($user->id, $period);

            return response()->json([
                'success' => true,
                'data' => $summary,
                'message' => 'Financial summary retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving financial summary: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get expense breakdown by category
     */
    public function getExpenseBreakdown(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $period = $request->get('period', 'monthly');

            $breakdown = $this->financialReportService->getExpenseBreakdown($user->id, $period);

            return response()->json([
                'success' => true,
                'data' => $breakdown,
                'message' => 'Expense breakdown retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving expense breakdown: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get budget vs actual spending comparison
     */
    public function getBudgetVsActual(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $period = $request->get('period', 'monthly');

            $comparison = $this->financialReportService->getBudgetVsActual($user->id, $period);

            return response()->json([
                'success' => true,
                'data' => $comparison,
                'message' => 'Budget vs actual comparison retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving budget vs actual comparison: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get savings goals progress
     */
    public function getSavingsGoalsProgress(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $progress = $this->financialReportService->getSavingsGoalsProgress($user->id);

            return response()->json([
                'success' => true,
                'data' => $progress,
                'message' => 'Savings goals progress retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving savings goals progress: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get upcoming bills
     */
    public function getUpcomingBills(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $days = $request->get('days', 30);

            $bills = $this->financialReportService->getUpcomingBills($user->id, $days);

            return response()->json([
                'success' => true,
                'data' => $bills,
                'message' => 'Upcoming bills retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving upcoming bills: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get comprehensive financial report
     */
    public function getComprehensiveReport(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $period = $request->get('period', 'monthly');

            $summary = $this->financialReportService->getFinancialSummary($user->id, $period);
            $breakdown = $this->financialReportService->getExpenseBreakdown($user->id, $period);
            $budgetComparison = $this->financialReportService->getBudgetVsActual($user->id, $period);
            $savingsProgress = $this->financialReportService->getSavingsGoalsProgress($user->id);
            $upcomingBills = $this->financialReportService->getUpcomingBills($user->id, 30);

            $report = [
                'summary' => $summary,
                'expense_breakdown' => $breakdown,
                'budget_comparison' => $budgetComparison,
                'savings_progress' => $savingsProgress,
                'upcoming_bills' => $upcomingBills
            ];

            return response()->json([
                'success' => true,
                'data' => $report,
                'message' => 'Comprehensive financial report retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving comprehensive financial report: ' . $e->getMessage()
            ], 500);
        }
    }
}
