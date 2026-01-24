<?php

namespace App\Repositories;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class TransactionRepository implements TransactionRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = Transaction::where('user_id', $userId)->with(['category', 'billReminder', 'savingsGoal']);

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
            ->with(['category', 'billReminder', 'savingsGoal'])
            ->first();
    }

    public function create(array $data): Transaction
    {
        \Log::info('Repository: Creating transaction', ['data' => $data]);

        // Validasi bahwa category_id milik pengguna (jika disediakan dan bukan null)
        if (isset($data['category_id']) && $data['category_id'] !== null) {
            $category = \App\Models\Category::where('id', $data['category_id'])
                ->where('user_id', $data['user_id'])
                ->first();
            if (!$category) {
                throw new \Exception('Category does not belong to user');
            }
        }

        // Validasi bahwa bill_reminder_id milik pengguna (jika disediakan dan bukan null)
        if (isset($data['bill_reminder_id']) && $data['bill_reminder_id'] !== null) {
            $billReminder = \App\Models\BillReminder::where('id', $data['bill_reminder_id'])
                ->where('user_id', $data['user_id'])
                ->first();
            if (!$billReminder) {
                throw new \Exception('Bill reminder does not belong to user');
            }
        }

        // Validasi bahwa savings_goal_id milik pengguna (jika disediakan dan bukan null)
        if (isset($data['savings_goal_id']) && $data['savings_goal_id'] !== null) {
            $savingsGoal = \App\Models\SavingsGoal::where('id', $data['savings_goal_id'])
                ->where('user_id', $data['user_id'])
                ->first();
            if (!$savingsGoal) {
                throw new \Exception('Savings goal does not belong to user');
            }
        }

        // Buat transaksi tanpa eager loading untuk mencegah masalah dengan relasi
        $transaction = Transaction::create($data);
        \Log::info('Repository: Transaction created', ['id' => $transaction->id]);

        // Refresh model untuk memuat relasi yang valid
        $transaction->load(['category', 'billReminder', 'savingsGoal']);

        return $transaction;
    }

    public function update(int $id, int $userId, array $data): ?Transaction
    {
        $transaction = $this->getById($id, $userId);

        if ($transaction) {
            // Validasi bahwa category_id milik pengguna (jika disediakan dan bukan null)
            if (isset($data['category_id']) && $data['category_id'] !== null) {
                $category = \App\Models\Category::where('id', $data['category_id'])
                    ->where('user_id', $userId)
                    ->first();
                if (!$category) {
                    throw new \Exception('Category does not belong to user');
                }
            }

            // Validasi bahwa bill_reminder_id milik pengguna (jika disediakan dan bukan null)
            if (isset($data['bill_reminder_id']) && $data['bill_reminder_id'] !== null) {
                $billReminder = \App\Models\BillReminder::where('id', $data['bill_reminder_id'])
                    ->where('user_id', $userId)
                    ->first();
                if (!$billReminder) {
                    throw new \Exception('Bill reminder does not belong to user');
                }
            }

            // Validasi bahwa savings_goal_id milik pengguna (jika disediakan dan bukan null)
            if (isset($data['savings_goal_id']) && $data['savings_goal_id'] !== null) {
                $savingsGoal = \App\Models\SavingsGoal::where('id', $data['savings_goal_id'])
                    ->where('user_id', $userId)
                    ->first();
                if (!$savingsGoal) {
                    throw new \Exception('Savings goal does not belong to user');
                }
            }

            $transaction->update($data);

            // Refresh model untuk memuat relasi yang valid
            $transaction->load(['category', 'billReminder', 'savingsGoal']);

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
            ->with(['category', 'billReminder', 'savingsGoal'])
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

    public function getMonthlyTransactions(int $userId, int $month, int $year): array
    {
        $transactions = Transaction::where('user_id', $userId)
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->with(['category', 'billReminder', 'savingsGoal'])
            ->orderBy('date', 'desc')
            ->get();

        return $transactions->toArray();
    }
}
