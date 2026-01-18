<?php

namespace App\Services;

use App\Models\FinancialNotification;
use App\Models\Budget;
use App\Models\SavingsGoal;
use App\Models\BillReminder;
use App\Models\Transaction;
use Carbon\Carbon;

class FinancialNotificationService
{
    /**
     * Generate and send financial notifications based on user's financial status
     */
    public function generateFinancialNotifications(int $userId)
    {
        $notifications = [];
        
        // 1. Budget alerts - when user is approaching or exceeding budget
        $budgetAlerts = $this->generateBudgetAlerts($userId);
        $notifications = array_merge($notifications, $budgetAlerts);
        
        // 2. Savings reminders - when user is behind on savings goals
        $savingsReminders = $this->generateSavingsReminders($userId);
        $notifications = array_merge($notifications, $savingsReminders);
        
        // 3. Bill reminders - upcoming and overdue bills
        $billReminders = $this->generateBillReminders($userId);
        $notifications = array_merge($notifications, $billReminders);
        
        // 4. Financial insights notifications
        $insightNotifications = $this->generateInsightNotifications($userId);
        $notifications = array_merge($notifications, $insightNotifications);
        
        // Save all notifications to database
        foreach ($notifications as $notification) {
            FinancialNotification::create([
                'user_id' => $userId,
                'type' => $notification['type'],
                'title' => $notification['title'],
                'message' => $notification['message'],
                'priority' => $notification['priority'],
                'data' => $notification['data'],
                'is_read' => false,
                'is_action_required' => $notification['is_action_required'],
                'sent_at' => Carbon::now(),
            ]);
        }
        
        return $notifications;
    }
    
    /**
     * Generate budget alerts
     */
    private function generateBudgetAlerts(int $userId)
    {
        $notifications = [];
        $currentMonth = Carbon::now()->format('Y-m');
        
        $budgets = Budget::where('user_id', $userId)
            ->where('month', $currentMonth)
            ->get();
        
        foreach ($budgets as $budget) {
            $percentageUsed = $budget->amount > 0 ? ($budget->spent_amount / $budget->amount) * 100 : 0;
            
            if ($percentageUsed >= 90 && $percentageUsed < 100) {
                // Near budget limit
                $notifications[] = [
                    'type' => 'budget_alert',
                    'title' => 'Anggaran Hampir Habis',
                    'message' => 'Anggaran untuk kategori ' . ($budget->category ? $budget->category->name : 'umum') . ' telah mencapai ' . round($percentageUsed, 1) . '% dari total Rp ' . number_format($budget->amount, 0, ',', '.'),
                    'priority' => 'high',
                    'data' => [
                        'budget_id' => $budget->id,
                        'category' => $budget->category ? $budget->category->name : 'umum',
                        'percentage_used' => $percentageUsed,
                        'remaining_amount' => $budget->amount - $budget->spent_amount
                    ],
                    'is_action_required' => true
                ];
            } elseif ($percentageUsed >= 100) {
                // Over budget
                $notifications[] = [
                    'type' => 'budget_alert',
                    'title' => 'Melebihi Anggaran',
                    'message' => 'Anda telah melebihi anggaran untuk kategori ' . ($budget->category ? $budget->category->name : 'umum') . ' sebesar Rp ' . number_format($budget->spent_amount - $budget->amount, 0, ',', '.'),
                    'priority' => 'critical',
                    'data' => [
                        'budget_id' => $budget->id,
                        'category' => $budget->category ? $budget->category->name : 'umum',
                        'excess_amount' => $budget->spent_amount - $budget->amount
                    ],
                    'is_action_required' => true
                ];
            }
        }
        
        return $notifications;
    }
    
    /**
     * Generate savings reminders
     */
    private function generateSavingsReminders(int $userId)
    {
        $notifications = [];
        
        $savingsGoals = SavingsGoal::where('user_id', $userId)
            ->where('status', 'active')
            ->get();
        
        foreach ($savingsGoals as $goal) {
            $targetDate = Carbon::parse($goal->target_date);
            $daysRemaining = $targetDate->diffInDays(Carbon::today());
            $amountRemaining = $goal->target_amount - $goal->current_amount;
            
            if ($daysRemaining > 0) {
                $requiredDailySavings = $amountRemaining / $daysRemaining;
                $currentDailySavings = $goal->current_amount / (Carbon::today()->diffInDays(Carbon::parse($goal->created_at)) + 1);
                
                if ($currentDailySavings < $requiredDailySavings * 0.7) {
                    // Savings progress is too slow
                    $notifications[] = [
                        'type' => 'savings_reminder',
                        'title' => 'Progres Tabungan Lambat',
                        'message' => 'Progres tabungan untuk "' . $goal->name . '" lebih lambat dari target. Anda perlu menabung Rp ' . number_format($requiredDailySavings, 0, ',', '.') . ' per hari untuk mencapai target.',
                        'priority' => 'medium',
                        'data' => [
                            'savings_goal_id' => $goal->id,
                            'goal_name' => $goal->name,
                            'required_daily_savings' => $requiredDailySavings,
                            'current_daily_savings' => $currentDailySavings,
                            'days_remaining' => $daysRemaining,
                            'amount_remaining' => $amountRemaining
                        ],
                        'is_action_required' => true
                    ];
                }
            }
        }
        
        return $notifications;
    }
    
    /**
     * Generate bill reminders
     */
    private function generateBillReminders(int $userId)
    {
        $notifications = [];
        
        // Get bills due in the next 7 days
        $upcomingBills = BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->where('due_date', '<=', Carbon::today()->addDays(7))
            ->where('due_date', '>=', Carbon::today())
            ->get();
        
        foreach ($upcomingBills as $bill) {
            $daysUntilDue = Carbon::parse($bill->due_date)->diffInDays(Carbon::today());
            
            if ($daysUntilDue <= 3) {
                // Urgent bill reminder
                $notifications[] = [
                    'type' => 'bill_reminder',
                    'title' => 'Pembayaran Tagihan Segera Jatuh Tempo',
                    'message' => 'Tagihan "' . $bill->name . '" sebesar Rp ' . number_format($bill->amount, 0, ',', '.') . ' akan jatuh tempo dalam ' . $daysUntilDue . ' hari.',
                    'priority' => 'high',
                    'data' => [
                        'bill_reminder_id' => $bill->id,
                        'bill_name' => $bill->name,
                        'amount' => $bill->amount,
                        'due_date' => $bill->due_date,
                        'days_until_due' => $daysUntilDue
                    ],
                    'is_action_required' => true
                ];
            } else {
                // Regular upcoming bill reminder
                $notifications[] = [
                    'type' => 'bill_reminder',
                    'title' => 'Tagihan Akan Jatuh Tempo',
                    'message' => 'Tagihan "' . $bill->name . '" sebesar Rp ' . number_format($bill->amount, 0, ',', '.') . ' akan jatuh tempo pada ' . $bill->due_date . '.',
                    'priority' => 'medium',
                    'data' => [
                        'bill_reminder_id' => $bill->id,
                        'bill_name' => $bill->name,
                        'amount' => $bill->amount,
                        'due_date' => $bill->due_date,
                        'days_until_due' => $daysUntilDue
                    ],
                    'is_action_required' => true
                ];
            }
        }
        
        // Get overdue bills
        $overdueBills = BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->where('due_date', '<', Carbon::today())
            ->get();
        
        foreach ($overdueBills as $bill) {
            $daysOverdue = Carbon::today()->diffInDays(Carbon::parse($bill->due_date));
            
            $notifications[] = [
                'type' => 'bill_reminder',
                'title' => 'Tagihan Terlambat',
                'message' => 'Tagihan "' . $bill->name . '" sebesar Rp ' . number_format($bill->amount, 0, ',', '.') . ' telah terlambat selama ' . $daysOverdue . ' hari.',
                'priority' => 'critical',
                'data' => [
                    'bill_reminder_id' => $bill->id,
                    'bill_name' => $bill->name,
                    'amount' => $bill->amount,
                    'due_date' => $bill->due_date,
                    'days_overdue' => $daysOverdue
                ],
                'is_action_required' => true
            ];
        }
        
        return $notifications;
    }
    
    /**
     * Generate insight notifications
     */
    private function generateInsightNotifications(int $userId)
    {
        $notifications = [];
        
        // Check if user has unusual spending compared to previous month
        $spendingTrend = $this->analyzeSpendingTrend($userId);
        if ($spendingTrend['is_increasing']) {
            $notifications[] = [
                'type' => 'insight_notification',
                'title' => 'Pengeluaran Meningkat',
                'message' => 'Pengeluaran Anda meningkat ' . $spendingTrend['percentage_increase'] . '% dalam 3 bulan terakhir. Mungkin perlu meninjau anggaran Anda.',
                'priority' => 'medium',
                'data' => [
                    'current_spending' => $spendingTrend['current_spending'],
                    'previous_spending' => $spendingTrend['previous_spending'],
                    'percentage_increase' => $spendingTrend['percentage_increase']
                ],
                'is_action_required' => false
            ];
        }
        
        return $notifications;
    }
    
    /**
     * Analyze spending trend
     */
    private function analyzeSpendingTrend(int $userId)
    {
        $currentMonth = Carbon::now()->startOfMonth();
        $threeMonthsAgo = Carbon::now()->subMonths(3)->startOfMonth();
        
        $currentSpending = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('date', [$currentMonth, Carbon::now()])
            ->sum('amount');
            
        $threeMonthsAgoSpending = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereBetween('date', [$threeMonthsAgo, $currentMonth->copy()->subDay()])
            ->sum('amount');
        
        $isIncreasing = $threeMonthsAgoSpending > 0 && $currentSpending > $threeMonthsAgoSpending;
        $percentageIncrease = $threeMonthsAgoSpending > 0 
            ? round((($currentSpending - $threeMonthsAgoSpending) / $threeMonthsAgoSpending) * 100, 2)
            : 0;
        
        return [
            'is_increasing' => $isIncreasing,
            'percentage_increase' => $percentageIncrease,
            'current_spending' => $currentSpending,
            'previous_spending' => $threeMonthsAgoSpending
        ];
    }
    
    /**
     * Get unread notifications for user
     */
    public function getUnreadNotifications(int $userId)
    {
        return FinancialNotification::where('user_id', $userId)
            ->where('is_read', false)
            ->orderBy('priority', 'desc')
            ->orderBy('created_at', 'desc')
            ->get();
    }
    
    /**
     * Mark notification as read
     */
    public function markNotificationAsRead(int $notificationId, int $userId)
    {
        $notification = FinancialNotification::where('id', $notificationId)
            ->where('user_id', $userId)
            ->first();
            
        if ($notification) {
            $notification->update(['is_read' => true]);
            return true;
        }
        
        return false;
    }
    
    /**
     * Get notifications by type
     */
    public function getNotificationsByType(int $userId, string $type)
    {
        return FinancialNotification::where('user_id', $userId)
            ->where('type', $type)
            ->orderBy('created_at', 'desc')
            ->get();
    }
    
    /**
     * Get recent notifications
     */
    public function getRecentNotifications(int $userId, int $limit = 10)
    {
        return FinancialNotification::where('user_id', $userId)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }
}