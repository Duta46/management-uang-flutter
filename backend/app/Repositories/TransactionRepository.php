<?php

namespace App\Repositories;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class TransactionRepository implements TransactionRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = Transaction::where('user_id', $userId)->with(['category']);

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }
        
        if (isset($filters['start_date']) && isset($filters['end_date'])) {
            $query->whereBetween('date', [$filters['start_date'], $filters['end_date']]);
        }
        
        if (isset($filters['category_id'])) {
            $query->where('category_id', $filters['category_id']);
        }

        return $query->orderBy('date', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getById(int $id, int $userId): ?Transaction
    {
        return Transaction::where('id', $id)
            ->where('user_id', $userId)
            ->with(['category'])
            ->first();
    }

    public function create(array $data): Transaction
    {
        return Transaction::create($data);
    }

    public function update(int $id, int $userId, array $data): ?Transaction
    {
        $transaction = $this->getById($id, $userId);
        
        if ($transaction) {
            $transaction->update($data);
            return $transaction;
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $transaction = $this->getById($id, $userId);
        
        if ($transaction) {
            return $transaction->delete();
        }

        return false;
    }

    public function getTransactionsByDateRange(int $userId, string $startDate, string $endDate): Collection
    {
        return Transaction::where('user_id', $userId)
            ->whereBetween('date', [$startDate, $endDate])
            ->with(['category'])
            ->get();
    }

    public function getSummaryByMonth(int $userId, int $month, int $year): array
    {
        $income = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->sum('amount');

        $expense = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->sum('amount');

        return [
            'income' => $income,
            'expense' => $expense,
            'balance' => $income - $expense
        ];
    }
}