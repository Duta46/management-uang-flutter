<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Notification\BillReminderNotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class BillReminderNotificationController extends Controller
{
    private BillReminderNotificationService $notificationService;

    public function __construct(BillReminderNotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Get all bill notifications for the authenticated user
     */
    public function getBillNotifications(Request $request): JsonResponse
    {
        $userId = auth()->id();
        
        $daysAhead = $request->input('days_ahead', 7);
        
        $notifications = $this->notificationService->getAllBillNotifications($userId, $daysAhead);

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'count' => count($notifications),
            'message' => count($notifications) > 0 
                ? 'Notifikasi tagihan berhasil diambil' 
                : 'Tidak ada notifikasi tagihan',
        ]);
    }

    /**
     * Get upcoming due bills for the authenticated user
     */
    public function getUpcomingBills(Request $request): JsonResponse
    {
        $userId = auth()->id();
        
        $daysAhead = $request->input('days_ahead', 7);
        
        $notifications = $this->notificationService->getUpcomingDueBills($userId, $daysAhead);

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'count' => count($notifications),
            'message' => count($notifications) > 0 
                ? 'Tagihan mendatang berhasil diambil' 
                : 'Tidak ada tagihan mendatang',
        ]);
    }

    /**
     * Get overdue bills for the authenticated user
     */
    public function getOverdueBills(Request $request): JsonResponse
    {
        $userId = auth()->id();
        
        $notifications = $this->notificationService->getOverdueBills($userId);

        return response()->json([
            'success' => true,
            'data' => $notifications,
            'count' => count($notifications),
            'message' => count($notifications) > 0 
                ? 'Tagihan terlambat berhasil diambil' 
                : 'Tidak ada tagihan terlambat',
        ]);
    }

    /**
     * Check if user has any bill notifications
     */
    public function hasBillNotifications(Request $request): JsonResponse
    {
        $userId = auth()->id();
        
        $daysAhead = $request->input('days_ahead', 7);
        
        $hasNotifications = $this->notificationService->hasBillNotifications($userId, $daysAhead);

        return response()->json([
            'success' => true,
            'has_notifications' => $hasNotifications,
            'message' => $hasNotifications 
                ? 'Pengguna memiliki notifikasi tagihan' 
                : 'Pengguna tidak memiliki notifikasi tagihan',
        ]);
    }
}