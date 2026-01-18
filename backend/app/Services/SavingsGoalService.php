<?php

namespace App\Services;

use App\Models\SavingsGoal;
use App\Repositories\SavingsGoalRepositoryInterface;
use Carbon\Carbon;

class SavingsGoalService
{
    private SavingsGoalRepositoryInterface $savingsGoalRepository;

    public function __construct(SavingsGoalRepositoryInterface $savingsGoalRepository)
    {
        $this->savingsGoalRepository = $savingsGoalRepository;
    }

    /**
     * Calculate progress percentage for a savings goal
     */
    public function calculateProgress(SavingsGoal $savingsGoal): float
    {
        if ($savingsGoal->target_amount == 0) {
            return 0;
        }

        return round(($savingsGoal->current_amount / $savingsGoal->target_amount) * 100, 2);
    }

    /**
     * Get days remaining to reach the savings goal
     */
    public function getDaysRemaining(SavingsGoal $savingsGoal): int
    {
        $targetDate = Carbon::parse($savingsGoal->target_date);
        $today = Carbon::today();

        return $targetDate->diffInDays($today);
    }

    /**
     * Get status of savings goal (on track, behind, achieved, etc.)
     */
    public function getSavingsGoalStatus(SavingsGoal $savingsGoal): string
    {
        if ($savingsGoal->status !== 'active') {
            return $savingsGoal->status;
        }

        if ($savingsGoal->current_amount >= $savingsGoal->target_amount) {
            return 'achieved';
        }

        $progress = $this->calculateProgress($savingsGoal);
        $daysRemaining = $this->getDaysRemaining($savingsGoal);

        // Jika sudah mencapai target
        if ($progress >= 100) {
            return 'achieved';
        }

        // Jika tanggal target sudah lewat dan belum tercapai
        if ($daysRemaining <= 0) {
            return 'behind_schedule';
        }

        // Jika progres lambat
        $dailyRequired = ($savingsGoal->target_amount - $savingsGoal->current_amount) / $daysRemaining;
        $dailyProgress = $savingsGoal->current_amount / (Carbon::today()->diffInDays(Carbon::parse($savingsGoal->created_at)) + 1);

        if ($dailyProgress < $dailyRequired * 0.7) {
            return 'behind_schedule';
        }

        return 'on_track';
    }

    /**
     * Get all savings goals with their status and progress
     */
    public function getSavingsGoalsWithStatus(int $userId)
    {
        try {
            \Log::info('Getting savings goals with status', ['user_id' => $userId]);

            $savingsGoals = $this->savingsGoalRepository->getByUserId($userId);

            // Tidak perlu menambahkan status dan progress karena sudah ada di model sebagai accessor
            // Progress, amount_needed, days_remaining, dan status_text sudah dihitung otomatis oleh accessor

            \Log::info('Retrieved savings goals with status', ['count' => count($savingsGoals), 'user_id' => $userId]);

            return $savingsGoals;
        } catch (\Exception $e) {
            \Log::error('Exception in getting savings goals with status', ['user_id' => $userId, 'error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            throw $e;
        }
    }
}