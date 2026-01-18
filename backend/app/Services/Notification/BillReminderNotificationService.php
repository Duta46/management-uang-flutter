<?php

namespace App\Services\Notification;

use App\Models\BillReminder;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class BillReminderNotificationService
{
    /**
     * Get upcoming due bills for a user
     * 
     * @param int $userId
     * @param int $daysAhead Number of days ahead to check
     * @return array
     */
    public function getUpcomingDueBills(int $userId, int $daysAhead = 7): array
    {
        $today = Carbon::today();
        $endDate = $today->copy()->addDays($daysAhead);

        $bills = BillReminder::where('user_id', $userId)
            ->where('is_active', true)
            ->where('is_paid', false)
            ->whereBetween('next_due_date', [$today, $endDate])
            ->orderBy('next_due_date', 'asc')
            ->get();

        $notifications = [];
        foreach ($bills as $bill) {
            $daysUntilDue = $today->diffInDays(Carbon::parse($bill->next_due_date), false);
            
            $notification = [
                'id' => $bill->id,
                'title' => 'Tagihan Jatuh Tempo',
                'message' => "Tagihan '{$bill->name}' sebesar Rp " . number_format($bill->amount, 0, ',', '.') . " akan jatuh tempo dalam {$daysUntilDue} hari",
                'due_date' => $bill->next_due_date,
                'amount' => $bill->amount,
                'name' => $bill->name,
                'type' => 'bill_reminder',
                'priority' => $daysUntilDue <= 1 ? 'high' : ($daysUntilDue <= 3 ? 'medium' : 'low'),
                'created_at' => now(),
            ];

            $notifications[] = $notification;
        }

        return $notifications;
    }

    /**
     * Get overdue bills for a user
     * 
     * @param int $userId
     * @return array
     */
    public function getOverdueBills(int $userId): array
    {
        $today = Carbon::today();

        $overdueBills = BillReminder::where('user_id', $userId)
            ->where('is_active', true)
            ->where('is_paid', false)
            ->whereDate('next_due_date', '<', $today)
            ->orderBy('next_due_date', 'desc')
            ->get();

        $notifications = [];
        foreach ($overdueBills as $bill) {
            $daysOverdue = $today->diffInDays(Carbon::parse($bill->next_due_date), false);
            
            $notification = [
                'id' => $bill->id,
                'title' => 'Tagihan Terlambat',
                'message' => "Tagihan '{$bill->name}' sebesar Rp " . number_format($bill->amount, 0, ',', '.') . " telah terlambat selama {$daysOverdue} hari",
                'due_date' => $bill->next_due_date,
                'amount' => $bill->amount,
                'name' => $bill->name,
                'type' => 'bill_reminder_overdue',
                'priority' => 'high',
                'created_at' => now(),
            ];

            $notifications[] = $notification;
        }

        return $notifications;
    }

    /**
     * Get all bill notifications for a user (upcoming and overdue)
     * 
     * @param int $userId
     * @param int $daysAhead Number of days ahead to check for upcoming bills
     * @return array
     */
    public function getAllBillNotifications(int $userId, int $daysAhead = 7): array
    {
        $upcomingBills = $this->getUpcomingDueBills($userId, $daysAhead);
        $overdueBills = $this->getOverdueBills($userId);

        // Combine and sort by priority and due date
        $allNotifications = array_merge($upcomingBills, $overdueBills);
        
        usort($allNotifications, function ($a, $b) {
            // Sort by priority first (high > medium > low)
            $priorityOrder = [
                'high' => 3,
                'medium' => 2,
                'low' => 1,
            ];
            
            if ($priorityOrder[$a['priority']] !== $priorityOrder[$b['priority']]) {
                return $priorityOrder[$b['priority']] - $priorityOrder[$a['priority']];
            }
            
            // Then sort by due date
            return Carbon::parse($a['due_date'])->compareTo(Carbon::parse($b['due_date']));
        });

        return $allNotifications;
    }

    /**
     * Check if there are any bill notifications for a user
     * 
     * @param int $userId
     * @param int $daysAhead Number of days ahead to check
     * @return bool
     */
    public function hasBillNotifications(int $userId, int $daysAhead = 7): bool
    {
        return count($this->getAllBillNotifications($userId, $daysAhead)) > 0;
    }
}