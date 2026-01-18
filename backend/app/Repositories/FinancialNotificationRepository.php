<?php

namespace App\Repositories;

use App\Models\FinancialNotification;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class FinancialNotificationRepository implements FinancialNotificationRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = FinancialNotification::where('user_id', $userId);

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['is_read'])) {
            $query->where('is_read', $filters['is_read']);
        }

        return $query->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getById(int $id, int $userId): ?FinancialNotification
    {
        return FinancialNotification::where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    public function create(array $data): FinancialNotification
    {
        return FinancialNotification::create($data);
    }

    public function update(int $id, int $userId, array $data): ?FinancialNotification
    {
        $notification = $this->getById($id, $userId);

        if ($notification) {
            $notification->update($data);
            return $notification;
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $notification = $this->getById($id, $userId);

        if ($notification) {
            return $notification->delete();
        }

        return false;
    }

    public function getUnreadByUserId(int $userId): Collection
    {
        return FinancialNotification::where('user_id', $userId)
            ->where('is_read', false)
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function markAsRead(int $id, int $userId): bool
    {
        $notification = $this->getById($id, $userId);

        if ($notification) {
            $notification->update(['is_read' => true]);
            return true;
        }

        return false;
    }
}