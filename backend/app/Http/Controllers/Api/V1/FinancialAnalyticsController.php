<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\FinancialAnalyticsService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class FinancialAnalyticsController extends Controller
{
    protected FinancialAnalyticsService $financialAnalyticsService;

    public function __construct(FinancialAnalyticsService $financialAnalyticsService)
    {
        $this->financialAnalyticsService = $financialAnalyticsService;
    }

    /**
     * Get financial insights
     */
    public function getInsights(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $insights = $this->financialAnalyticsService->generateFinancialInsights($user->id);

            return response()->json([
                'success' => true,
                'data' => $insights,
                'message' => 'Financial insights retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving financial insights: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get unread financial insights
     */
    public function getUnreadInsights(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $insights = $this->financialAnalyticsService->getUnreadInsights($user->id);

            return response()->json([
                'success' => true,
                'data' => $insights,
                'message' => 'Unread financial insights retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving unread financial insights: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark insight as read
     */
    public function markInsightAsRead(Request $request, int $id): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $success = $this->financialAnalyticsService->markInsightAsRead($id, $user->id);

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Insight marked as read successfully'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Insight not found or already belongs to another user'
                ], 404);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while marking insight as read: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get budget recommendations
     */
    public function getBudgetRecommendations(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $recommendations = $this->financialAnalyticsService->generateBudgetRecommendations($user->id);

            return response()->json([
                'success' => true,
                'data' => $recommendations,
                'message' => 'Budget recommendations retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving budget recommendations: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get financial predictions
     */
    public function getPredictions(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $predictions = $this->financialAnalyticsService->predictFinancialStatus($user->id);

            return response()->json([
                'success' => true,
                'data' => $predictions,
                'message' => 'Financial predictions retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving financial predictions: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get financial health score
     */
    public function getFinancialHealthScore(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $healthScore = $this->financialAnalyticsService->generateFinancialHealthScore($user->id);

            return response()->json([
                'success' => true,
                'data' => $healthScore,
                'message' => 'Financial health score retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving financial health score: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get comprehensive financial analysis
     */
    public function getComprehensiveAnalysis(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $insights = $this->financialAnalyticsService->generateFinancialInsights($user->id);
            $recommendations = $this->financialAnalyticsService->generateBudgetRecommendations($user->id);
            $predictions = $this->financialAnalyticsService->predictFinancialStatus($user->id);
            $healthScore = $this->financialAnalyticsService->generateFinancialHealthScore($user->id);

            $analysis = [
                'insights' => $insights,
                'recommendations' => $recommendations,
                'predictions' => $predictions,
                'health_score' => $healthScore
            ];

            return response()->json([
                'success' => true,
                'data' => $analysis,
                'message' => 'Comprehensive financial analysis retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving comprehensive financial analysis: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all financial recommendations
     */
    public function getFinancialRecommendations(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $recommendations = $this->financialAnalyticsService->getFinancialRecommendations($user->id);

            return response()->json([
                'success' => true,
                'data' => $recommendations,
                'message' => 'Financial recommendations retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving financial recommendations: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get budget recommendations from database
     */
    public function getBudgetRecommendationsFromDB(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $recommendations = $this->financialAnalyticsService->getBudgetRecommendationsFromDB($user->id);

            return response()->json([
                'success' => true,
                'data' => $recommendations,
                'message' => 'Budget recommendations retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving budget recommendations from database: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark recommendation as applied
     */
    public function markRecommendationAsApplied(Request $request, int $id): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $success = $this->financialAnalyticsService->markRecommendationAsApplied($id, $user->id);

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Recommendation marked as applied successfully'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Recommendation not found or already belongs to another user'
                ], 404);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while marking recommendation as applied: ' . $e->getMessage()
            ], 500);
        }
    }
}
