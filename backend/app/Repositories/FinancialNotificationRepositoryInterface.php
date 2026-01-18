<?php

namespace App\Repositories;

use App\Models\FinancialNotification;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface FinancialNotificationRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator;
    public function getById(int $id, int $userId): ?FinancialNotification;
    public function create(array $data): FinancialNotification;
    public function update(int $id, int $userId, array $data): ?FinancialNotification;
    public function delete(int $id, int $userId): bool;
    public function getUnreadByUserId(int $userId): Collection;
    public function markAsRead(int $id, int $userId): bool;
}