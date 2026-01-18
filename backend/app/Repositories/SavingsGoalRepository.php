<?php

namespace App\Repositories;

use App\Models\SavingsGoal;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class SavingsGoalRepository implements SavingsGoalRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        \Log::info('Repository: Getting all savings goals', ['user_id' => $userId, 'filters' => $filters]);

        $query = SavingsGoal::where('user_id', $userId);

        if (isset($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        $result = $query->orderBy('target_date', 'asc')->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);

        \Log::info('Repository: Retrieved savings goals', ['count' => $result->count(), 'user_id' => $userId]);

        return $result;
    }

    public function getById(int $id, int $userId): ?SavingsGoal
    {
        \Log::info('Repository: Getting savings goal by ID', ['id' => $id, 'user_id' => $userId]);

        $result = SavingsGoal::where('id', $id)
            ->where('user_id', $userId)
            ->first();

        \Log::info('Repository: Found savings goal', ['id' => $id, 'found' => $result !== null]);

        return $result;
    }

    public function create(array $data): SavingsGoal
    {
        \Log::info('Repository: Creating savings goal', ['data' => $data]);

        $result = SavingsGoal::create($data);

        \Log::info('Repository: Created savings goal', ['id' => $result->id]);

        return $result;
    }

    public function update(int $id, int $userId, array $data): ?SavingsGoal
    {
        \Log::info('Repository: Updating savings goal', ['id' => $id, 'user_id' => $userId, 'data' => $data]);

        $savingsGoal = $this->getById($id, $userId);

        if ($savingsGoal) {
            $savingsGoal->update($data);
            \Log::info('Repository: Updated savings goal', ['id' => $id]);
            return $savingsGoal;
        }

        \Log::warning('Repository: Savings goal not found for update', ['id' => $id, 'user_id' => $userId]);

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        \Log::info('Repository: Deleting savings goal', ['id' => $id, 'user_id' => $userId]);

        $savingsGoal = $this->getById($id, $userId);

        if ($savingsGoal) {
            $deleted = $savingsGoal->delete();
            \Log::info('Repository: Deleted savings goal', ['id' => $id, 'deleted' => $deleted]);
            return $deleted;
        }

        \Log::warning('Repository: Savings goal not found for deletion', ['id' => $id, 'user_id' => $userId]);

        return false;
    }

    public function getByUserId(int $userId): Collection
    {
        \Log::info('Repository: Getting savings goals by user ID', ['user_id' => $userId]);
        $result = SavingsGoal::where('user_id', $userId)->get();
        \Log::info('Repository: Retrieved savings goals', ['count' => $result->count(), 'user_id' => $userId]);
        return $result;
    }
}