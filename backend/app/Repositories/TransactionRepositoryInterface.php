<?php

namespace App\Repositories;

use App\Models\Transaction;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface TransactionRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator;
    public function getById(int $id, int $userId): ?Transaction;
    public function create(array $data): Transaction;
    public function update(int $id, int $userId, array $data): ?Transaction;
    public function delete(int $id, int $userId): bool;
    public function getTransactionsByDateRange(int $userId, string $startDate, string $endDate): Collection;
    public function getSummaryByMonth(int $userId, int $month, int $year): array;
}