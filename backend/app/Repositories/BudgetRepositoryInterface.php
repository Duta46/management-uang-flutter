<?php

namespace App\Repositories;

use App\Models\Budget;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface BudgetRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator;
    public function getById(int $id, int $userId): ?Budget;
    public function create(array $data): Budget;
    public function update(int $id, int $userId, array $data): ?Budget;
    public function delete(int $id, int $userId): bool;
    public function getByUserIdAndMonth(int $userId, string $month): Collection;
    public function getByUserId(int $userId): Collection;
}