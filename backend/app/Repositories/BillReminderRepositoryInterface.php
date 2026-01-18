<?php

namespace App\Repositories;

use App\Models\BillReminder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface BillReminderRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator;
    public function getById(int $id, int $userId): ?BillReminder;
    public function create(array $data): BillReminder;
    public function update(int $id, int $userId, array $data): ?BillReminder;
    public function delete(int $id, int $userId): bool;
    public function getUnpaidByUserId(int $userId): Collection;
    public function getByUserIdAndStatus(int $userId, string $status): LengthAwarePaginator;
    public function getByUserId(int $userId, bool $activeOnly = false): Collection;
}