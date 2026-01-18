<?php

namespace App\Services;

use App\Repositories\TransactionRepositoryInterface;
use App\Repositories\BillReminderRepositoryInterface;
use App\Models\Transaction;
use App\Models\BillReminder;
use Illuminate\Pagination\LengthAwarePaginator;

class TransactionService implements TransactionServiceInterface
{
    private TransactionRepositoryInterface $transactionRepository;
    private BillReminderRepositoryInterface $billReminderRepository;

    public function __construct(
        TransactionRepositoryInterface $transactionRepository,
        BillReminderRepositoryInterface $billReminderRepository
    ) {
        $this->transactionRepository = $transactionRepository;
        $this->billReminderRepository = $billReminderRepository;
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
        try {
            \Log::info('Service: Creating transaction', ['user_id' => $data['user_id'], 'data' => $data]);

            // Validasi data sebelum membuat transaksi
            $this->validateTransactionData($data);

            // Jika transaksi terkait dengan bill reminder, tandai bill sebagai dibayar
            if (isset($data['bill_reminder_id']) && $data['bill_reminder_id']) {
                \Log::info('Service: Processing bill reminder payment', ['bill_reminder_id' => $data['bill_reminder_id'], 'user_id' => $data['user_id']]);

                // Validasi bahwa bill reminder aktif sebelum diproses
                $billReminder = $this->billReminderRepository->getById($data['bill_reminder_id'], $data['user_id']);
                if ($billReminder && !$billReminder->is_active) {
                    throw new \Exception('Cannot create transaction with inactive bill reminder');
                }

                $this->handleBillPayment($data['bill_reminder_id'], $data['user_id']);
            }

            // Jika transaksi terkait dengan savings goal, lakukan update jumlah
            if (isset($data['savings_goal_id']) && $data['savings_goal_id']) {
                \Log::info('Service: Processing savings goal update', ['savings_goal_id' => $data['savings_goal_id'], 'amount' => $data['amount']]);

                // Validasi bahwa savings goal belum tercapai sebelum diproses
                $savingsGoal = \App\Models\SavingsGoal::find($data['savings_goal_id']);
                if ($savingsGoal && $savingsGoal->status === 'achieved') {
                    throw new \Exception('Cannot create transaction with achieved savings goal');
                }

                $this->updateSavingsGoalAmount($data['savings_goal_id'], $data['amount']);
            }

            $transaction = $this->transactionRepository->create($data);

            \Log::info('Service: Transaction created successfully', ['transaction_id' => $transaction->id]);

            return $transaction;
        } catch (\Exception $e) {
            \Log::error('Service: Error creating transaction', ['error' => $e->getMessage(), 'trace' => $e->getTraceAsString()]);
            throw $e;
        }
    }

    public function updateTransaction(int $id, int $userId, array $data): ?Transaction
    {
        $this->validateTransactionData($data);

        $transaction = $this->transactionRepository->getById($id, $userId);
        if (!$transaction) {
            return null;
        }

        \Log::info('Service: Updating transaction', [
            'transaction_id' => $id,
            'user_id' => $userId,
            'old_bill_reminder_id' => $transaction->bill_reminder_id,
            'new_bill_reminder_id' => $data['bill_reminder_id'] ?? null,
            'old_savings_goal_id' => $transaction->savings_goal_id,
            'new_savings_goal_id' => $data['savings_goal_id'] ?? null,
            'data' => $data
        ]);

        // Jika bill_reminder_id diubah, tangani pembayaran bill yang lama dan baru
        if (isset($data['bill_reminder_id']) && $data['bill_reminder_id'] !== $transaction->bill_reminder_id) {
            // Tandai bill lama sebagai belum dibayar jika transaksi ini adalah pembayaran untuk bill tersebut
            if ($transaction->bill_reminder_id) {
                $this->markBillAsUnpaid($transaction->bill_reminder_id);
            }

            // Validasi bahwa bill reminder aktif sebelum diproses
            $billReminder = $this->billReminderRepository->getById($data['bill_reminder_id'], $userId);
            if ($billReminder && !$billReminder->is_active) {
                throw new \Exception('Cannot update transaction with inactive bill reminder');
            }

            // Tandai bill baru sebagai dibayar
            $this->handleBillPayment($data['bill_reminder_id'], $userId);
        } elseif (isset($data['bill_reminder_id']) && $data['bill_reminder_id'] === $transaction->bill_reminder_id) {
            // Jika bill_reminder_id tidak berubah, tetap tandai bill sebagai dibayar

            // Validasi bahwa bill reminder aktif sebelum diproses
            $billReminder = $this->billReminderRepository->getById($data['bill_reminder_id'], $userId);
            if ($billReminder && !$billReminder->is_active) {
                throw new \Exception('Cannot update transaction with inactive bill reminder');
            }

            $this->handleBillPayment($data['bill_reminder_id'], $userId);
        }

        // Jika savings_goal_id diubah, tangani update jumlah tabungan
        if (isset($data['savings_goal_id']) && $data['savings_goal_id'] !== $transaction->savings_goal_id) {
            // Kurangi jumlah dari savings goal lama jika transaksi ini adalah bagian dari savings goal tersebut
            if ($transaction->savings_goal_id) {
                $this->decrementSavingsGoalAmount($transaction->savings_goal_id, $transaction->amount);
            }

            // Validasi bahwa savings goal baru belum tercapai sebelum diproses
            $savingsGoal = \App\Models\SavingsGoal::find($data['savings_goal_id']);
            if ($savingsGoal && $savingsGoal->status === 'achieved') {
                throw new \Exception('Cannot update transaction with achieved savings goal');
            }

            // Tambahkan jumlah ke savings goal baru
            $this->updateSavingsGoalAmount($data['savings_goal_id'], $data['amount'] ?? $transaction->amount);
        } elseif (isset($data['savings_goal_id']) && $data['savings_goal_id'] === $transaction->savings_goal_id) {
            // Jika savings_goal_id tidak berubah tetapi jumlah transaksi berubah
            // Validasi bahwa savings goal belum tercapai sebelum diproses
            $savingsGoal = \App\Models\SavingsGoal::find($data['savings_goal_id']);
            if ($savingsGoal && $savingsGoal->status === 'achieved') {
                throw new \Exception('Cannot update transaction with achieved savings goal');
            }

            $amountDifference = (($data['amount'] ?? $transaction->amount) - $transaction->amount);
            $this->updateSavingsGoalAmount($data['savings_goal_id'], $amountDifference);
        }

        return $this->transactionRepository->update($id, $userId, $data);
    }

    public function deleteTransaction(int $id, int $userId): bool
    {
        $transaction = $this->transactionRepository->getById($id, $userId);
        if (!$transaction) {
            return false;
        }

        \Log::info('Service: Deleting transaction', [
            'transaction_id' => $id,
            'user_id' => $userId,
            'bill_reminder_id' => $transaction->bill_reminder_id,
            'savings_goal_id' => $transaction->savings_goal_id,
            'amount' => $transaction->amount
        ]);

        // Jika transaksi terkait dengan bill reminder, tandai bill sebagai belum dibayar
        if ($transaction->bill_reminder_id) {
            // Hanya proses jika bill reminder aktif
            $billReminder = BillReminder::find($transaction->bill_reminder_id);
            if ($billReminder && $billReminder->is_active) {
                $this->markBillAsUnpaid($transaction->bill_reminder_id);
            }
        }

        // Jika transaksi terkait dengan savings goal, kurangi jumlah dari savings goal
        if ($transaction->savings_goal_id) {
            // Hanya proses jika savings goal belum tercapai
            $savingsGoal = \App\Models\SavingsGoal::find($transaction->savings_goal_id);
            if ($savingsGoal && $savingsGoal->status !== 'achieved') {
                $this->decrementSavingsGoalAmount($transaction->savings_goal_id, $transaction->amount);
            }
        }

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

        // Validasi bahwa jika category_id disediakan, nilainya harus positif
        if (isset($data['category_id']) && $data['category_id'] !== null && $data['category_id'] <= 0) {
            throw new \InvalidArgumentException('Category ID must be greater than 0 when provided');
        }
    }

    private function handleBillPayment(int $billReminderId, int $userId): void
    {
        $billReminder = $this->billReminderRepository->getById($billReminderId, $userId);

        if ($billReminder && $billReminder->is_active) { // Hanya proses jika pengingat tagihan aktif
            $billReminder->update(['is_paid' => true]);
        }
    }

    private function updateSavingsGoalAmount(int $savingsGoalId, float $amount): void
    {
        // Ambil savings goal dan tambahkan jumlah ke current_amount
        $savingsGoal = \App\Models\SavingsGoal::find($savingsGoalId);
        if ($savingsGoal) {
            $savingsGoal->increment('current_amount', $amount);

            // Cek apakah target sudah tercapai setelah penambahan
            if ($savingsGoal->current_amount >= $savingsGoal->target_amount) {
                // Jika target tercapai, ubah status menjadi 'achieved'
                $savingsGoal->update(['status' => 'achieved']);
            } else {
                // Jika belum tercapai, pastikan statusnya bukan 'achieved'
                if ($savingsGoal->status === 'achieved') {
                    $savingsGoal->update(['status' => 'active']);
                }
            }
        }
    }

    private function decrementSavingsGoalAmount(int $savingsGoalId, float $amount): void
    {
        // Ambil savings goal dan kurangi jumlah dari current_amount
        $savingsGoal = \App\Models\SavingsGoal::find($savingsGoalId);
        if ($savingsGoal) {
            $savingsGoal->decrement('current_amount', $amount);

            // Cek apakah target masih tercapai setelah pengurangan
            if ($savingsGoal->current_amount < $savingsGoal->target_amount) {
                // Jika target tidak lagi tercapai, ubah status kembali ke 'active'
                if ($savingsGoal->status === 'achieved') {
                    $savingsGoal->update(['status' => 'active']);
                }
            }
        }
    }

    private function markBillAsUnpaid(int $billReminderId): void
    {
        // Kita tidak bisa mendapatkan user_id dari auth() di sini,
        // jadi kita hanya akan mengupdate status is_paid tanpa memvalidasi user
        $billReminder = BillReminder::find($billReminderId);
        if ($billReminder && $billReminder->is_active) { // Hanya proses jika pengingat tagihan aktif
            $billReminder->update(['is_paid' => false]);
        }
    }
}