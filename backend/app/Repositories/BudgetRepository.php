<?php

namespace App\Repositories;

use App\Models\Budget;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class BudgetRepository implements BudgetRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = Budget::where('user_id', $userId)->with(['category']);

        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        if (isset($filters['month'])) {
            $query->where('month', $filters['month']);
        }

        return $query->orderBy('month', 'desc')->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getById(int $id, int $userId): ?Budget
    {
        return Budget::where('id', $id)
            ->where('user_id', $userId)
            ->with(['category'])
            ->first();
    }

    public function create(array $data): Budget
    {
        return Budget::create($data);
    }

    public function update(int $id, int $userId, array $data): ?Budget
    {
        $budget = $this->getById($id, $userId);

        if ($budget) {
            $budget->update($data);
            return $budget;
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $budget = $this->getById($id, $userId);

        if ($budget) {
            return $budget->delete();
        }

        return false;
    }

    public function getByUserIdAndMonth(int $userId, string $month): Collection
    {
        return Budget::where('user_id', $userId)
            ->where('month', $month)
            ->with(['category'])
            ->get();
    }

    public function getByUserId(int $userId): Collection
    {
        return Budget::where('user_id', $userId)
            ->with(['category'])
            ->get();
    }
}