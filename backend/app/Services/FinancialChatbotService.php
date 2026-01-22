<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use App\Repositories\TransactionRepositoryInterface;
use App\Repositories\SavingsGoalRepositoryInterface;
use App\Repositories\BudgetRepositoryInterface;
use App\Models\ChatbotConversation;
use App\Models\Transaction;
use Carbon\Carbon;

/**
 * Financial Chatbot Service with Local Implementation
 * Handles processing of financial questions using local rules and logic
 */
class FinancialChatbotService implements FinancialChatbotServiceInterface
{
    private $transactionRepository;
    private $savingsGoalRepository;
    private $budgetRepository;

    public function __construct(
        TransactionRepositoryInterface $transactionRepository,
        SavingsGoalRepositoryInterface $savingsGoalRepository,
        BudgetRepositoryInterface $budgetRepository
    ) {
        $this->transactionRepository = $transactionRepository;
        $this->savingsGoalRepository = $savingsGoalRepository;
        $this->budgetRepository = $budgetRepository;
    }

    /**
     * Process user's financial question and return answer using Qwen AI via OpenRouter
     */
    public function processQuestion(int $userId, string $question): array
    {
        // First, try to extract financial intent from the question
        $intent = $this->analyzeQuestionIntent($question);

        if ($intent['type'] !== 'unknown') {
            // Process the specific financial query
            $result = $this->processSpecificQuery($userId, $question, $intent);

            if ($result) {
                // Save the conversation
                $this->saveConversation($userId, $question, $result, $intent);

                return [
                    'success' => true,
                    'answer' => $result,
                    'intent' => $intent
                ];
            }
        }

        // If specific processing fails, use Qwen AI via OpenRouter for general response
        $response = $this->getGeneralResponse($userId, $question);

        // Save the conversation
        $this->saveConversation($userId, $question, $response['answer'], $response['intent'] ?? []);

        return $response;
    }

    /**
     * Analyze the intent of the financial question for local chatbot
     */
    private function analyzeQuestionIntent(string $question): array
    {
        $question = strtolower($question);

        // Define patterns for different financial queries
        $patterns = [
            'expense_total' => [
                'keywords' => ['berapa total pengeluaran', 'jumlah pengeluaran', 'total belanja', 'uang yang dikeluarkan', 'pengeluaran bulan ini', 'pengeluaran bulan lalu', 'pengeluaran minggu ini'],
                'time_patterns' => ['bulan ini', 'bulan lalu', 'minggu ini', 'minggu lalu', 'tahun ini', 'hari ini', 'kemarin'],
                'category_patterns' => ['makan', 'transportasi', 'laundry', 'hiburan', 'tagihan', 'sekolah', 'kost', 'pulsa', 'bensin', 'belanja']
            ],
            'income_total' => [
                'keywords' => ['berapa total pemasukan', 'jumlah pemasukan', 'total pendapatan', 'uang yang masuk', 'pemasukan bulan ini', 'pemasukan bulan lalu', 'pemasukan minggu ini'],
                'time_patterns' => ['bulan ini', 'bulan lalu', 'minggu ini', 'minggu lalu', 'tahun ini', 'hari ini', 'kemarin']
            ],
            'balance' => [
                'keywords' => ['saldo', 'uang saya', 'uang tersisa', 'uang sekarang', 'uang saat ini', 'berapakah uang saya', 'berapa uang saya']
            ],
            'category_expense' => [
                'keywords' => ['pengeluaran untuk', 'uang untuk', 'biaya untuk', 'berapa biaya', 'berapa pengeluaran untuk'],
                'category_patterns' => ['makan', 'transportasi', 'laundry', 'hiburan', 'tagihan', 'sekolah', 'kost', 'pulsa', 'bensin', 'belanja']
            ],
            'future_transactions' => [
                'keywords' => ['transaksi bulan depan', 'tunjukkan transaksi bulan depan', 'uang bulan depan', 'rencana pengeluaran bulan depan', 'rencana pemasukan bulan depan']
            ],
            'yearly_expense_income' => [
                'keywords' => ['pengeluaran tahun', 'pemasukan tahun', 'uang tahun', 'keuangan tahun', 'total tahun', 'jumlah tahun'],
                'year_patterns' => ['2024', '2025', '2026', '2027', '2028', '2029', '2030', 'tahun ini', 'tahun depan', 'tahun lalu']
            ],
            'transaction_list' => [
                'keywords' => ['transaksi terakhir', 'riwayat transaksi', 'data transaksi', 'semua transaksi', 'tunjukkan transaksi']
            ],
            'savings_goals' => [
                'keywords' => ['tabungan', 'rencana tabungan', 'tujuan tabungan', 'target tabungan', 'progres tabungan']
            ],
            'budget_info' => [
                'keywords' => ['anggaran', 'rencana pengeluaran', 'batas pengeluaran', 'anggaran bulan ini', 'anggaran bulan depan']
            ]
        ];

        foreach ($patterns as $type => $pattern) {
            foreach ($pattern['keywords'] as $keyword) {
                if (strpos($question, $keyword) !== false) {
                    $intent = [
                        'type' => $type,
                        'keyword' => $keyword
                    ];

                    // Extract time period if available
                    if (isset($pattern['time_patterns'])) {
                        foreach ($pattern['time_patterns'] as $time) {
                            if (strpos($question, $time) !== false) {
                                $intent['time_period'] = $time;
                                break;
                            }
                        }
                    }

                    // Extract category if available
                    if (isset($pattern['category_patterns'])) {
                        foreach ($pattern['category_patterns'] as $category) {
                            if (strpos($question, $category) !== false) {
                                $intent['category'] = $category;
                                break;
                            }
                        }
                    }

                    // Extract year if available (especially for yearly_expense_income intent)
                    if (isset($pattern['year_patterns'])) {
                        foreach ($pattern['year_patterns'] as $yearPattern) {
                            if (preg_match('/\b' . preg_quote($yearPattern) . '\b/i', $question, $matches)) {
                                $extractedYear = $matches[0];

                                // Convert special terms to actual years
                                if ($extractedYear === 'tahun ini') {
                                    $intent['year'] = date('Y');
                                } elseif ($extractedYear === 'tahun depan') {
                                    $intent['year'] = date('Y') + 1;
                                } elseif ($extractedYear === 'tahun lalu') {
                                    $intent['year'] = date('Y') - 1;
                                } elseif (is_numeric($extractedYear)) {
                                    $intent['year'] = (int)$extractedYear;
                                }
                                break;
                            }
                        }
                    }

                    return $intent;
                }
            }
        }

        return ['type' => 'unknown'];
    }

    /**
     * Process specific financial queries for local chatbot
     */
    private function processSpecificQuery(int $userId, string $question, array $intent): ?string
    {
        switch ($intent['type']) {
            case 'expense_total':
                return $this->calculateExpenseTotal($userId, $intent);
            case 'income_total':
                return $this->calculateIncomeTotal($userId, $intent);
            case 'category_expense':
                return $this->calculateCategoryExpense($userId, $intent);
            case 'balance':
                return $this->calculateBalance($userId);
            case 'future_transactions':
                return $this->getFutureTransactions($userId);
            case 'yearly_expense_income':
                return $this->calculateYearlyExpenseIncome($userId, $intent);
            case 'transaction_list':
                return $this->getTransactionList($userId, $intent);
            case 'savings_goals':
                return $this->getSavingsGoalsInfo($userId);
            case 'budget_info':
                return $this->getBudgetInfo($userId);
            default:
                return null;
        }
    }

    /**
     * Calculate expense total based on intent for Qwen AI via OpenRouter
     */
    private function calculateExpenseTotal(int $userId, array $intent): string
    {
        $filters = [
            'type' => 'expense',
            'limit' => 1000
        ];

        // Add date filters based on time period
        if (isset($intent['time_period'])) {
            $dateRange = $this->getDateRangeFromPeriod($intent['time_period']);
            $filters['start_date'] = $dateRange['start'];
            $filters['end_date'] = $dateRange['end'];
        }

        $transactions = $this->transactionRepository->getAll($userId, $filters);

        $total = 0;
        $categoryExpenses = [];
        $savingsAmount = 0; // Amount spent on savings-related categories
        $billsAmount = 0;   // Amount spent on bills-related categories

        foreach ($transactions as $transaction) {
            $total += $transaction->amount;

            // Group expenses by category
            $categoryName = $transaction->category ? $transaction->category->name : 'Umum';
            if (!isset($categoryExpenses[$categoryName])) {
                $categoryExpenses[$categoryName] = 0;
            }
            $categoryExpenses[$categoryName] += $transaction->amount;

            // Identify savings and bills categories
            $lowerCategory = strtolower($categoryName);
            if (strpos($lowerCategory, 'tabung') !== false || strpos($lowerCategory, 'saving') !== false || strpos($lowerCategory, 'invest') !== false) {
                $savingsAmount += $transaction->amount;
            } elseif (strpos($lowerCategory, 'tagih') !== false || strpos($lowerCategory, 'bill') !== false || strpos($lowerCategory, 'pajak') !== false) {
                $billsAmount += $transaction->amount;
            }
        }

        $timeDesc = $this->getTimeDescription($intent['time_period'] ?? 'unknown');

        // Format the response with total and breakdown by category
        $response = "Berikut adalah informasi pengeluaran {$timeDesc}:\n";
        $response .= "Total pengeluaran: Rp " . number_format($total, 0, ',', '.') . "\n\n";

        // Show savings and bills information if they exist
        if ($savingsAmount > 0) {
            $response .= "Total pengeluaran untuk tujuan tabungan/investasi: Rp " . number_format($savingsAmount, 0, ',', '.') . "\n";
        }

        if ($billsAmount > 0) {
            $response .= "Total pengeluaran untuk pembayaran tagihan: Rp " . number_format($billsAmount, 0, ',', '.') . "\n";
        }

        $response .= "\nRincian pengeluaran berdasarkan kategori:\n";

        foreach ($categoryExpenses as $category => $amount) {
            $response .= "- {$category}: Rp " . number_format($amount, 0, ',', '.') . "\n";
        }

        return $response;
    }

    /**
     * Calculate category-specific expense for Qwen AI via OpenRouter
     */
    private function calculateCategoryExpense(int $userId, array $intent): string
    {
        $filters = [
            'type' => 'expense',
            'limit' => 1000
        ];

        // Add date filters based on time period
        if (isset($intent['time_period'])) {
            $dateRange = $this->getDateRangeFromPeriod($intent['time_period']);
            $filters['start_date'] = $dateRange['start'];
            $filters['end_date'] = $dateRange['end'];
        }

        $transactions = $this->transactionRepository->getAll($userId, $filters);

        // Find transactions matching the category
        $categoryTransactions = [];
        $categoryName = $intent['category'] ?? '';

        foreach ($transactions as $transaction) {
            // Handle potential null category
            $transactionCategory = $transaction->category ? strtolower($transaction->category->name) : '';
            if (strpos($transactionCategory, $categoryName) !== false) {
                $categoryTransactions[] = $transaction;
            }
        }

        $total = array_sum(array_map(function($t) { return $t->amount; }, $categoryTransactions));

        $timeDesc = $this->getTimeDescription($intent['time_period'] ?? 'unknown');
        return "Total pengeluaran untuk {$categoryName} {$timeDesc} adalah Rp " . number_format($total, 0, ',', '.');
    }

    /**
     * Calculate income total for Qwen AI via OpenRouter
     */
    private function calculateIncomeTotal(int $userId, array $intent): string
    {
        $filters = [
            'type' => 'income',
            'limit' => 1000
        ];

        // Add date filters based on time period
        if (isset($intent['time_period'])) {
            $dateRange = $this->getDateRangeFromPeriod($intent['time_period']);
            $filters['start_date'] = $dateRange['start'];
            $filters['end_date'] = $dateRange['end'];
        }

        $transactions = $this->transactionRepository->getAll($userId, $filters);

        $total = 0;
        foreach ($transactions as $transaction) {
            $total += $transaction->amount;
        }

        $timeDesc = $this->getTimeDescription($intent['time_period'] ?? 'unknown');
        return "Total pemasukan {$timeDesc} adalah Rp " . number_format($total, 0, ',', '.');
    }

    /**
     * Calculate current balance for Qwen AI via OpenRouter
     */
    private function calculateBalance(int $userId): string
    {
        $allTransactions = $this->transactionRepository->getAll($userId, ['limit' => 1000]);

        $income = 0;
        $expense = 0;

        foreach ($allTransactions as $transaction) {
            if ($transaction->type === 'income') {
                $income += $transaction->amount;
            } else {
                $expense += $transaction->amount;
            }
        }

        $balance = $income - $expense;

        $balanceText = $balance >= 0 ? "Rp " . number_format($balance, 0, ',', '.') : "Rp " . number_format(abs($balance), 0, ',', '.') . " (defisit)";

        return "Saldo Anda saat ini adalah {$balanceText}";
    }

    /**
     * Get future transactions for Qwen AI via OpenRouter
     */
    private function getFutureTransactions(int $userId): string
    {
        // Get transactions for next month
        $nextMonthStart = now()->addMonth()->startOfMonth();
        $nextMonthEnd = now()->addMonth()->endOfMonth();

        $filters = [
            'limit' => 1000,
            'start_date' => $nextMonthStart->format('Y-m-d'),
            'end_date' => $nextMonthEnd->format('Y-m-d')
        ];

        $transactions = $this->transactionRepository->getAll($userId, $filters);

        if ($transactions->isEmpty()) {
            return "Maaf, bulan depan tidak ada transaksi yang tercatat. Transaksi hanya akan muncul setelah Anda menambahkannya.";
        }

        $transactionList = [];
        foreach ($transactions as $transaction) {
            $typeText = $transaction->type === 'income' ? 'Pemasukan' : 'Pengeluaran';
            $transactionList[] = "- {$typeText}: Rp " . number_format($transaction->amount, 0, ',', '.') . " (" . $transaction->description . ")";
        }

        $transactionCount = count($transactionList);
        $transactionText = $transactionCount === 1 ? "terdapat {$transactionCount} transaksi" : "terdapat {$transactionCount} transaksi";

        return "Untuk bulan depan, {$transactionText}:\n" . implode("\n", $transactionList);
    }

    /**
     * Calculate yearly expense and income for Qwen AI via OpenRouter
     */
    private function calculateYearlyExpenseIncome(int $userId, array $intent): string
    {
        // Ekstrak tahun dari intent atau dari pertanyaan
        $year = null;

        // Cek apakah tahun disebutkan dalam intent
        if (isset($intent['year'])) {
            $year = $intent['year'];
        } else {
            // Coba ekstrak tahun dari pertanyaan
            $question = $intent['keyword'] ?? '';
            $year = $this->extractYearFromQuestion($question);
        }

        if ($year === null) {
            // Jika tidak bisa mengekstrak tahun, beri tahu pengguna
            return "Untuk permintaan tentang tahun tertentu, mohon sertakan tahun yang dimaksud. Contoh: 'pengeluaran tahun 2026' atau 'pemasukan tahun 2027'.";
        }

        // Cek apakah tahun yang diminta adalah tahun saat ini
        $currentYear = date('Y');

        if ($year > $currentYear) {
            // Untuk tahun di masa depan, beri tahu bahwa belum ada datanya
            return "Maaf, untuk tahun {$year} belum ada data transaksi yang tercatat. Data hanya akan muncul setelah Anda menambahkan transaksi untuk tahun tersebut.";
        }

        // Untuk tahun yang valid, ambil data dari database
        $startDate = \Carbon\Carbon::createFromDate($year, 1, 1)->startOfDay();
        $endDate = \Carbon\Carbon::createFromDate($year, 12, 31)->endOfDay();

        $incomeQuery = Transaction::where('user_id', $userId)
            ->where('type', 'income')
            ->whereDate('date', '>=', $startDate->format('Y-m-d'))
            ->whereDate('date', '<=', $endDate->format('Y-m-d'));

        $expenseQuery = Transaction::where('user_id', $userId)
            ->where('type', 'expense')
            ->whereDate('date', '>=', $startDate->format('Y-m-d'))
            ->whereDate('date', '<=', $endDate->format('Y-m-d'));

        $income = $incomeQuery->sum('amount');
        $expense = $expenseQuery->sum('amount');

        if ($income == 0 && $expense == 0) {
            if ($year == $currentYear) {
                return "Untuk tahun ini ({$year}), Anda belum memiliki transaksi keuangan yang tercatat. Silakan tambahkan transaksi untuk melihat ringkasan tahunan.";
            } else {
                return "Untuk tahun {$year}, Anda belum memiliki transaksi keuangan yang tercatat.";
            }
        }

        return "Berikut ringkasan keuangan Anda untuk tahun {$year}:\n" .
               "- Total Pemasukan: Rp " . number_format($income, 0, ',', '.') . "\n" .
               "- Total Pengeluaran: Rp " . number_format($expense, 0, ',', '.') . "\n" .
               "- Saldo: Rp " . number_format($income - $expense, 0, ',', '.');
    }

    /**
     * Extract year from question for Qwen AI via OpenRouter
     */
    private function extractYearFromQuestion(string $question): ?int
    {
        // Cari pola tahun (4 digit antara 2020-2030)
        $pattern = '/\b(20[2-3][0-9]|2040)\b/';
        preg_match($pattern, $question, $matches);

        if (!empty($matches[0])) {
            return (int)$matches[0];
        }

        // Cek apakah mengandung "tahun ini", "tahun depan", dll
        $currentYear = date('Y');
        $questionLower = strtolower($question);

        if (strpos($questionLower, 'tahun ini') !== false) {
            return (int)$currentYear;
        } elseif (strpos($questionLower, 'tahun depan') !== false) {
            return (int)$currentYear + 1;
        } elseif (strpos($questionLower, 'tahun lalu') !== false) {
            return (int)$currentYear - 1;
        }

        return null;
    }

    /**
     * Get date range based on time period for Qwen AI via OpenRouter
     */
    private function getDateRangeFromPeriod(string $period): array
    {
        switch ($period) {
            case 'bulan ini':
                return [
                    'start' => now()->startOfMonth()->format('Y-m-d'),
                    'end' => now()->endOfMonth()->format('Y-m-d')
                ];
            case 'bulan lalu':
                return [
                    'start' => now()->subMonth()->startOfMonth()->format('Y-m-d'),
                    'end' => now()->subMonth()->endOfMonth()->format('Y-m-d')
                ];
            case 'minggu ini':
                return [
                    'start' => now()->startOfWeek()->format('Y-m-d'),
                    'end' => now()->endOfWeek()->format('Y-m-d')
                ];
            case 'minggu lalu':
                return [
                    'start' => now()->subWeek()->startOfWeek()->format('Y-m-d'),
                    'end' => now()->subWeek()->endOfWeek()->format('Y-m-d')
                ];
            case 'tahun ini':
                return [
                    'start' => now()->startOfYear()->format('Y-m-d'),
                    'end' => now()->endOfYear()->format('Y-m-d')
                ];
            case 'hari ini':
                return [
                    'start' => now()->format('Y-m-d'),
                    'end' => now()->format('Y-m-d')
                ];
            case 'kemarin':
                return [
                    'start' => now()->subDay()->format('Y-m-d'),
                    'end' => now()->subDay()->format('Y-m-d')
                ];
            default:
                // Default to current month
                return [
                    'start' => now()->startOfMonth()->format('Y-m-d'),
                    'end' => now()->endOfMonth()->format('Y-m-d')
                ];
        }
    }

    /**
     * Get time period description for Qwen AI via OpenRouter
     */
    private function getTimeDescription(?string $period): string
    {
        switch ($period) {
            case 'bulan ini':
                return 'bulan ini';
            case 'bulan lalu':
                return 'bulan lalu';
            case 'minggu ini':
                return 'minggu ini';
            case 'minggu lalu':
                return 'minggu lalu';
            case 'tahun ini':
                return 'tahun ini';
            case 'hari ini':
                return 'hari ini';
            case 'kemarin':
                return 'kemarin';
            default:
                return 'bulan ini';
        }
    }

    /**
     * Get general response using local logic when specific processing fails
     */
    private function getGeneralResponse(int $userId, string $question): array
    {
        // Get user's financial data to provide context
        $recentTransactions = $this->transactionRepository->getAll($userId, [
            'limit' => 20,
            'start_date' => now()->subDays(30)->format('Y-m-d'),
            'end_date' => now()->format('Y-m-d')
        ]);

        $financialSummary = $this->generateFinancialSummary($recentTransactions->items());

        // Implement simple keyword-based response logic
        $questionLower = strtolower($question);

        // Check for common greetings or general questions
        if (strpos($questionLower, 'hai') !== false || strpos($questionLower, 'halo') !== false ||
            strpos($questionLower, 'hi') !== false || strpos($questionLower, 'hello') !== false) {
            // Determine greeting based on time in Jakarta timezone
            $currentTime = now()->timezone('Asia/Jakarta');
            $hour = $currentTime->hour;

            if ($hour >= 5 && $hour < 10) {
                $greeting = "Selamat pagi!";
            } elseif ($hour >= 10 && $hour < 15) {
                $greeting = "Selamat siang!";
            } elseif ($hour >= 15 && $hour < 18) {
                $greeting = "Selamat sore!";
            } else {
                $greeting = "Selamat malam!";
            }

            return [
                'success' => true,
                'answer' => "{$greeting} Saya asisten keuangan pribadi Anda. Saya bisa membantu Anda dengan informasi tentang pengeluaran, pemasukan, saldo, dan rencana keuangan Anda. Silakan tanyakan sesuatu tentang keuangan Anda.",
                'intent' => ['type' => 'greeting']
            ];
        }

        // Check for help request
        if (strpos($questionLower, 'bantu') !== false || strpos($questionLower, 'help') !== false ||
            strpos($questionLower, 'cara') !== false || strpos($questionLower, 'bagaimana') !== false) {
            return [
                'success' => true,
                'answer' => 'Saya bisa membantu Anda dengan berbagai hal keuangan seperti:\n- Menampilkan total pengeluaran/pemasukan\n- Menampilkan saldo keuangan\n- Menampilkan pengeluaran per kategori\n- Memberikan tips keuangan\n\nContoh pertanyaan: "Berapa total pengeluaran bulan ini?" atau "Berapa saldo saya saat ini?"',
                'intent' => ['type' => 'help']
            ];
        }

        // Check if the question is asking for specific data that might exist in the database
        if (strpos($questionLower, 'data') !== false || strpos($questionLower, 'riwayat') !== false ||
            strpos($questionLower, 'transaksi') !== false) {

            if ($recentTransactions->count() > 0) {
                $transactionList = "Berikut beberapa transaksi terakhir Anda:\n";
                foreach ($recentTransactions as $transaction) {
                    $typeText = $transaction->type === 'income' ? 'Pemasukan' : 'Pengeluaran';
                    $categoryName = $transaction->category ? $transaction->category->name : 'Umum';

                    // Format date to Indonesian format (e.g., "Januari pada tanggal 5")
                    $dateObj = \Carbon\Carbon::parse($transaction->date);
                    $months = [
                        '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
                        '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
                        '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'
                    ];
                    $monthName = $months[$dateObj->format('m')] ?? $dateObj->format('F');
                    $formattedDate = $monthName . " pada tanggal " . $dateObj->format('j');

                    $transactionList .= "- {$typeText}: Rp " . number_format($transaction->amount, 0, ',', '.') .
                                       " ({$categoryName}) pada " . $formattedDate . "\n";
                }

                return [
                    'success' => true,
                    'answer' => "Berikut adalah beberapa transaksi terakhir Anda:\n\n" . $transactionList . "\nDemikian informasi transaksi terbaru Anda. Jika Anda memerlukan detail lebih lanjut, silakan beri tahu saya.",
                    'intent' => ['type' => 'transaction_history']
                ];
            } else {
                return [
                    'success' => true,
                    'answer' => 'Saat ini Anda belum memiliki riwayat transaksi. Silakan tambahkan transaksi terlebih dahulu untuk melihat data keuangan Anda.',
                    'intent' => ['type' => 'no_data']
                ];
            }
        }

        // If no specific keywords matched, provide a generic response with user's financial summary
        $genericAnswer = "Terima kasih atas pertanyaan Anda: '{$question}'. Saat ini saya menyediakan informasi berdasarkan data keuangan Anda:\n\n{$financialSummary}\n\nJika Anda memiliki pertanyaan spesifik tentang keuangan Anda, silakan ajukan dengan jelas, misalnya tentang pengeluaran, pemasukan, atau saldo.";

        return [
            'success' => true,
            'answer' => $genericAnswer,
            'intent' => ['type' => 'general']
        ];
    }

    /**
     * Generate financial summary from transactions for local chatbot
     */
    private function generateFinancialSummary($transactions): string
    {
        if (empty($transactions)) {
            return "Pengguna belum memiliki data transaksi.";
        }

        $income = 0;
        $expense = 0;
        $categories = [];

        foreach ($transactions as $transaction) {
            if ($transaction->type === 'income') {
                $income += $transaction->amount;
            } else {
                $expense += $transaction->amount;
                // Handle potential null category
                $catName = $transaction->category ? $transaction->category->name : 'Umum';
                $categories[$catName] = ($categories[$catName] ?? 0) + $transaction->amount;
            }
        }

        $summary = "Ringkasan keuangan 30 hari terakhir:\n";
        $summary .= "- Total pemasukan: Rp " . number_format($income, 0, ',', '.') . "\n";
        $summary .= "- Total pengeluaran: Rp " . number_format($expense, 0, ',', '.') . "\n";
        $summary .= "- Sisa saldo: Rp " . number_format($income - $expense, 0, ',', '.') . "\n";
        $summary .= "- Kategori pengeluaran utama: ";

        arsort($categories);
        $topCategories = array_slice($categories, 0, 3, true);
        $categoryList = [];
        foreach ($topCategories as $cat => $amount) {
            $categoryList[] = "{$cat} (Rp " . number_format($amount, 0, ',', '.') . ")";
        }
        $summary .= implode(", ", $categoryList) . "\n";

        return $summary;
    }

    /**
     * Get transaction list for the user
     */
    private function getTransactionList(int $userId, array $intent): string
    {
        $limit = 10; // Default limit
        $filters = [
            'limit' => $limit
        ];

        $transactions = $this->transactionRepository->getAll($userId, $filters);

        if ($transactions->isEmpty()) {
            return "Anda belum memiliki transaksi apapun. Silakan tambahkan transaksi terlebih dahulu.";
        }

        $transactionList = "Berikut adalah " . min($limit, $transactions->count()) . " transaksi terakhir Anda:\n";
        foreach ($transactions as $transaction) {
            $typeText = $transaction->type === 'income' ? 'Pemasukan' : 'Pengeluaran';
            $categoryName = $transaction->category ? $transaction->category->name : 'Umum';

            // Format date to Indonesian format (e.g., "Januari pada tanggal 5")
            $dateObj = \Carbon\Carbon::parse($transaction->date);
            $months = [
                '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
                '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
                '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'
            ];
            $monthName = $months[$dateObj->format('m')] ?? $dateObj->format('F');
            $formattedDate = $monthName . " pada tanggal " . $dateObj->format('j');

            $transactionList .= "- {$typeText}: Rp " . number_format($transaction->amount, 0, ',', '.') .
                               " ({$categoryName}) pada " . $formattedDate . "\n";
        }

        return $transactionList;
    }

    /**
     * Get savings goals information for the user
     */
    private function getSavingsGoalsInfo(int $userId): string
    {
        $savingsGoals = $this->savingsGoalRepository->getAll($userId, ['limit' => 10]);

        if ($savingsGoals->isEmpty()) {
            return "Anda belum memiliki rencana tabungan saat ini.";
        }

        $savingsList = "Berikut adalah rencana tabungan Anda:\n";
        foreach ($savingsGoals as $goal) {
            $progress = $goal->target_amount > 0 ? round(($goal->current_amount / $goal->target_amount) * 100, 2) : 0;
            $savingsList .= "- {$goal->name}: Rp " . number_format($goal->current_amount, 0, ',', '.') .
                           " dari Rp " . number_format($goal->target_amount, 0, ',', '.') .
                           " ({$progress}% selesai)\n";
        }

        return $savingsList;
    }

    /**
     * Get budget information for the user
     */
    private function getBudgetInfo(int $userId): string
    {
        $budgets = $this->budgetRepository->getAll($userId, ['limit' => 10]);

        if ($budgets->isEmpty()) {
            return "Anda belum memiliki anggaran saat ini.";
        }

        $budgetList = "Berikut adalah anggaran Anda:\n";
        foreach ($budgets as $budget) {
            $spentAmount = $budget->spent_amount ?? 0;
            $remaining = $budget->allocated_amount - $spentAmount;
            $percentage = $budget->allocated_amount > 0 ? round(($spentAmount / $budget->allocated_amount) * 100, 2) : 0;

            // Handle potential null category
            $categoryName = $budget->category ? $budget->category->name : 'Umum';
            $budgetList .= "- {$categoryName}: Rp " . number_format($budget->allocated_amount, 0, ',', '.') .
                          " (terpakai: Rp " . number_format($spentAmount, 0, ',', '.') .
                          ", sisa: Rp " . number_format($remaining, 0, ',', '.') .
                          ", {$percentage}% dari alokasi)\n";
        }

        return $budgetList;
    }

    /**
     * Save conversation to database for local chatbot
     */
    private function saveConversation(int $userId, string $question, string $answer, array $intent): void
    {
        try {
            ChatbotConversation::create([
                'user_id' => $userId,
                'user_question' => $question,
                'ai_response' => $answer,
                'intent' => $intent,
                'conversation_type' => 'financial'
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to save chatbot conversation: ' . $e->getMessage());
        }
    }
}
