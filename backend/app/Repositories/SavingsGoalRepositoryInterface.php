<?php

namespace App\Repositories;

use App\Models\SavingsGoal;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface SavingsGoalRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator;
    public function getById(int $id, int $userId): ?SavingsGoal;
    public function create(array $data): SavingsGoal;
    public function update(int $id, int $userId, array $data): ?SavingsGoal;
    public function delete(int $id, int $userId): bool;
    public function getByUserId(int $userId): Collection;
}