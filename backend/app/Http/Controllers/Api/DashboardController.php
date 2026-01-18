<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\Notification\BillReminderNotificationService;
use App\Services\TransactionServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    private TransactionServiceInterface $transactionService;
    private BillReminderNotificationService $notificationService;

    public function __construct(
        TransactionServiceInterface $transactionService,
        BillReminderNotificationService $notificationService
    ) {
        $this->transactionService = $transactionService;
        $this->notificationService = $notificationService;
    }

    public function summary(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $month = $request->get('month', date('n')); // Current month if not provided
        $year = $request->get('year', date('Y'));  // Current year if not provided

        $summary = $this->transactionService->getMonthlySummary($userId, $month, $year);

        // Get bill reminder notifications
        $billNotifications = $this->notificationService->getAllBillNotifications($userId, 7);

        return response()->json([
            'success' => true,
            'data' => [
                'month' => $month,
                'year' => $year,
                'income' => $summary['income'],
                'expense' => $summary['expense'],
                'balance' => $summary['balance'],
                'bill_notifications' => [
                    'count' => count($billNotifications),
                    'upcoming_count' => count(array_filter($billNotifications, function($notification) {
                        return $notification['type'] === 'bill_reminder';
                    })),
                    'overdue_count' => count(array_filter($billNotifications, function($notification) {
                        return $notification['type'] === 'bill_reminder_overdue';
                    })),
                    'notifications' => $billNotifications
                ]
            ],
            'message' => 'Dashboard summary retrieved successfully'
        ]);
    }

    public function chart(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $month = $request->get('month', date('n')); // Current month if not provided
        $year = $request->get('year', date('Y'));  // Current year if not provided

        // Get transactions for the specified month
        $transactions = $this->transactionService->getAllTransactions($userId, [
            'start_date' => "$year-$month-01",
            'end_date' => date("Y-m-t", mktime(0, 0, 0, $month, 1, $year))
        ]);

        // Group transactions by category for chart
        $incomeByCategory = [];
        $expenseByCategory = [];

        foreach ($transactions as $transaction) {
            $categoryName = $transaction->category->name;
            $amount = $transaction->amount;

            if ($transaction->type === 'income') {
                $incomeByCategory[$categoryName] = ($incomeByCategory[$categoryName] ?? 0) + $amount;
            } else {
                $expenseByCategory[$categoryName] = ($expenseByCategory[$categoryName] ?? 0) + $amount;
            }
        }

        // Get bill reminder notifications
        $billNotifications = $this->notificationService->getAllBillNotifications($userId, 7);

        return response()->json([
            'success' => true,
            'data' => [
                'income_by_category' => $incomeByCategory,
                'expense_by_category' => $expenseByCategory,
                'bill_notifications' => [
                    'count' => count($billNotifications),
                    'upcoming_count' => count(array_filter($billNotifications, function($notification) {
                        return $notification['type'] === 'bill_reminder';
                    })),
                    'overdue_count' => count(array_filter($billNotifications, function($notification) {
                        return $notification['type'] === 'bill_reminder_overdue';
                    })),
                    'notifications' => $billNotifications
                ]
            ],
            'message' => 'Dashboard chart data retrieved successfully'
        ]);
    }

    /**
     * Get bill reminder notifications for the dashboard
     */
    public function billNotifications(Request $request): JsonResponse
    {
        $userId = auth()->id();
        $daysAhead = $request->input('days_ahead', 7);

        $billNotifications = $this->notificationService->getAllBillNotifications($userId, $daysAhead);

        return response()->json([
            'success' => true,
            'data' => [
                'count' => count($billNotifications),
                'upcoming_count' => count(array_filter($billNotifications, function($notification) {
                    return $notification['type'] === 'bill_reminder';
                })),
                'overdue_count' => count(array_filter($billNotifications, function($notification) {
                    return $notification['type'] === 'bill_reminder_overdue';
                })),
                'notifications' => $billNotifications
            ],
            'message' => count($billNotifications) > 0
                ? 'Notifikasi tagihan berhasil diambil'
                : 'Tidak ada notifikasi tagihan',
        ]);
    }
}