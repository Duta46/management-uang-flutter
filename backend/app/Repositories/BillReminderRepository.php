<?php

namespace App\Repositories;

use App\Models\BillReminder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class BillReminderRepository implements BillReminderRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = BillReminder::where('user_id', $userId);

        if (isset($filters['is_paid'])) {
            $query->where('is_paid', $filters['is_paid']);
        }

        if (isset($filters['is_active'])) {
            $query->where('is_active', $filters['is_active']);
        }

        if (isset($filters['frequency'])) {
            $query->where('frequency', $filters['frequency']);
        }

        return $query->orderBy('due_date', 'asc')->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getById(int $id, int $userId): ?BillReminder
    {
        return BillReminder::where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    public function create(array $data): BillReminder
    {
        return BillReminder::create($data);
    }

    public function update(int $id, int $userId, array $data): ?BillReminder
    {
        $billReminder = $this->getById($id, $userId);

        if ($billReminder) {
            $billReminder->update($data);
            return $billReminder;
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $billReminder = $this->getById($id, $userId);

        if ($billReminder) {
            return $billReminder->delete();
        }

        return false;
    }

    public function getUnpaidByUserId(int $userId): Collection
    {
        return BillReminder::where('user_id', $userId)
            ->where('is_paid', false)
            ->orderBy('due_date', 'asc')
            ->get();
    }

    public function getByUserIdAndStatus(int $userId, string $status): LengthAwarePaginator
    {
        $query = BillReminder::where('user_id', $userId);

        switch ($status) {
            case 'paid':
                $query->where('is_paid', true);
                break;
            case 'unpaid':
                $query->where('is_paid', false);
                break;
            case 'overdue':
                $query->where('is_paid', false)
                      ->where('due_date', '<', now());
                break;
            case 'upcoming':
                $query->where('is_paid', false)
                      ->where('due_date', '>=', now());
                break;
        }

        return $query->orderBy('due_date', 'asc')->paginate(15);
    }

    public function getByUserId(int $userId, bool $activeOnly = false): Collection
    {
        $query = BillReminder::where('user_id', $userId);

        if ($activeOnly) {
            $query->where('is_active', true);
        }

        return $query->get();
    }
}