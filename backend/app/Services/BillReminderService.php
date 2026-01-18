<?php

namespace App\Services;

use App\Models\BillReminder;
use App\Repositories\BillReminderRepositoryInterface;
use Carbon\Carbon;

class BillReminderService
{
    private BillReminderRepositoryInterface $billReminderRepository;

    public function __construct(BillReminderRepositoryInterface $billReminderRepository)
    {
        $this->billReminderRepository = $billReminderRepository;
    }

    /**
     * Get status of bill reminder (due, upcoming, paid, overdue)
     */
    public function getBillReminderStatus(BillReminder $billReminder): string
    {
        if ($billReminder->is_paid) {
            return 'paid';
        }

        $dueDate = Carbon::parse($billReminder->due_date);
        $today = Carbon::today();

        if ($today->gt($dueDate)) {
            return 'overdue';
        } elseif ($today->diffInDays($dueDate) <= 3) {
            return 'due_soon';
        } else {
            return 'upcoming';
        }
    }

    /**
     * Check if a bill reminder is due for renewal based on frequency
     */
    public function shouldRenewBill(BillReminder $billReminder): bool
    {
        if ($billReminder->frequency === 'one_time' || $billReminder->is_paid) {
            return false;
        }

        $nextDueDate = Carbon::parse($billReminder->next_due_date);
        $today = Carbon::today();

        return $today->gte($nextDueDate);
    }

    /**
     * Renew a bill reminder based on its frequency
     */
    public function renewBill(BillReminder $billReminder): BillReminder
    {
        $nextDueDate = Carbon::parse($billReminder->next_due_date);

        switch ($billReminder->frequency) {
            case 'weekly':
                $nextDueDate->addWeek();
                break;
            case 'monthly':
                $nextDueDate->addMonth();
                break;
            case 'yearly':
                $nextDueDate->addYear();
                break;
            default:
                // For one_time bills, don't renew
                return $billReminder;
        }

        $billReminder->update([
            'due_date' => $nextDueDate,
            'next_due_date' => $nextDueDate,
            'is_paid' => false
        ]);

        return $billReminder;
    }

    /**
     * Get all bill reminders with their status
     */
    public function getBillRemindersWithStatus(int $userId, bool $activeOnly = false)
    {
        $billReminders = $this->billReminderRepository->getByUserId($userId, $activeOnly); // Perlu menambahkan method ini ke interface

        foreach ($billReminders as $billReminder) {
            $billReminder->status = $this->getBillReminderStatus($billReminder);
            $billReminder->days_until_due = Carbon::today()->diffInDays(Carbon::parse($billReminder->due_date), false);
        }

        return $billReminders;
    }
}