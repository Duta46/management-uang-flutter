<?php

namespace App\Services;

use App\Repositories\TransactionRepositoryInterface;
use App\Models\Transaction;
use Illuminate\Pagination\LengthAwarePaginator;

class TransactionService implements TransactionServiceInterface
{
    private TransactionRepositoryInterface $transactionRepository;

    public function __construct(TransactionRepositoryInterface $transactionRepository)
    {
        $this->transactionRepository = $transactionRepository;
    }

    public function getAllTransactions(int $userId, array $filters = []): LengthAwarePaginator
    {
        return $this->transactionRepository->getAll($userId, $filters);
    }

    public function getTransaction(int $id, int $userId): ?Transaction
    {
        return $this->transactionRepository->getById($id, $userId);
    }

    public function createTransaction(array $data): Transaction
    {
        // Validasi data sebelum membuat transaksi
        $this->validateTransactionData($data);
        
        return $this->transactionRepository->create($data);
    }

    public function updateTransaction(int $id, int $userId, array $data): ?Transaction
    {
        $this->validateTransactionData($data);
        
        return $this->transactionRepository->update($id, $userId, $data);
    }

    public function deleteTransaction(int $id, int $userId): bool
    {
        return $this->transactionRepository->delete($id, $userId);
    }

    public function getMonthlySummary(int $userId, int $month, int $year): array
    {
        return $this->transactionRepository->getSummaryByMonth($userId, $month, $year);
    }

    private function validateTransactionData(array $data): void
    {
        // Validasi bahwa tipe transaksi adalah income atau expense
        if (!in_array($data['type'], ['income', 'expense'])) {
            throw new \InvalidArgumentException('Transaction type must be income or expense');
        }
        
        // Validasi bahwa jumlah transaksi positif
        if ($data['amount'] <= 0) {
            throw new \InvalidArgumentException('Amount must be greater than 0');
        }
    }
}