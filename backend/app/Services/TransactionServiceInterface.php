<?php

namespace App\Services;

use App\Repositories\TransactionRepositoryInterface;
use App\Models\Transaction;
use Illuminate\Pagination\LengthAwarePaginator;

interface TransactionServiceInterface
{
    public function getAllTransactions(int $userId, array $filters = []): LengthAwarePaginator;
    public function getTransaction(int $id, int $userId): ?Transaction;
    public function createTransaction(array $data): Transaction;
    public function updateTransaction(int $id, int $userId, array $data): ?Transaction;
    public function deleteTransaction(int $id, int $userId): bool;
    public function getMonthlySummary(int $userId, int $month, int $year): array;
}