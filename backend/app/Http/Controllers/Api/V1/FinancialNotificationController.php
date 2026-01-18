<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\FinancialNotificationService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class FinancialNotificationController extends Controller
{
    protected FinancialNotificationService $financialNotificationService;

    public function __construct(FinancialNotificationService $financialNotificationService)
    {
        $this->financialNotificationService = $financialNotificationService;
    }

    /**
     * Get all unread notifications for user
     */
    public function getUnreadNotifications(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $notifications = $this->financialNotificationService->getUnreadNotifications($user->id);

            return response()->json([
                'success' => true,
                'data' => $notifications,
                'message' => 'Unread notifications retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving unread notifications: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all notifications for user
     */
    public function getAllNotifications(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $notifications = $this->financialNotificationService->getRecentNotifications($user->id);

            return response()->json([
                'success' => true,
                'data' => $notifications,
                'message' => 'All notifications retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving all notifications: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get notifications by type
     */
    public function getNotificationsByType(Request $request, string $type): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $notifications = $this->financialNotificationService->getNotificationsByType($user->id, $type);

            return response()->json([
                'success' => true,
                'data' => $notifications,
                'message' => 'Notifications by type retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving notifications by type: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Mark notification as read
     */
    public function markAsRead(Request $request, int $id): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $success = $this->financialNotificationService->markNotificationAsRead($id, $user->id);

            if ($success) {
                return response()->json([
                    'success' => true,
                    'message' => 'Notification marked as read successfully'
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Notification not found or already belongs to another user'
                ], 404);
            }
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while marking notification as read: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Generate notifications manually
     */
    public function generateNotifications(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $notifications = $this->financialNotificationService->generateFinancialNotifications($user->id);

            return response()->json([
                'success' => true,
                'data' => $notifications,
                'message' => 'Financial notifications generated successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while generating notifications: ' . $e->getMessage()
            ], 500);
        }
    }
}
