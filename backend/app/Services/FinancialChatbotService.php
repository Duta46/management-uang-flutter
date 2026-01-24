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
    public function processQuestion(?int $userId, string $question): array
    {
        // First, try to extract financial intent from the question
        $intent = $this->analyzeQuestionIntent($question);

        if ($intent['type'] !== 'unknown' && $userId !== null) {
            // Process the specific financial query only if user is authenticated
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

        // If specific processing fails or user is not authenticated, use general response
        $response = $this->getGeneralResponse($userId ?? 0, $question);

        // Save the conversation only if user is authenticated
        if ($userId !== null) {
            $this->saveConversation($userId, $question, $response['answer'], $response['intent'] ?? []);
        }

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
            'next_month_prediction' => [
                'keywords' => ['prediksi bulan depan', 'proyeksi keuangan bulan depan', 'ramalan pengeluaran bulan depan', 'prediksi pengeluaran bulan depan', 'proyeksi pengeluaran bulan depan', 'prediksi keuangan bulan depan', 'analisis bulan depan', 'wawasan bulan depan', 'perkiraan keuangan bulan depan', 'proyeksi ke depan']
            ],
            'date_filtered_data' => [
                'keywords' => ['data bulan', 'transaksi bulan', 'keuangan bulan', 'pengeluaran bulan', 'pemasukan bulan', 'riwayat bulan', 'uang bulan', 'data tahun', 'transaksi tahun', 'keuangan tahun', 'pengeluaran tahun', 'pemasukan tahun', 'uang tahun'],
                'year_patterns' => ['2024', '2025', '2026', '2027', '2028', '2029', '2030', 'tahun ini', 'tahun depan', 'tahun lalu'],
                'time_patterns' => ['januari', 'februari', 'maret', 'april', 'mei', 'juni', 'juli', 'agustus', 'september', 'oktober', 'november', 'desember', 'bulan ini', 'bulan lalu']
            ],
            'financial_health' => [
                'keywords' => ['kesehatan keuangan', 'cek kesehatan keuangan', 'analisis kesehatan keuangan', 'evaluasi keuangan', 'penilaian keuangan', 'cek keuangan', 'analisis keuangan', 'evaluasi kesehatan keuangan', 'peringkat keuangan', 'skor keuangan', 'cek skor keuangan', 'evaluasi kondisi keuangan', 'analisis kondisi keuangan', 'kondisi keuangan', 'cek kondisi keuangan']
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
            ],
            'financial_insights' => [
                'keywords' => ['wawasan keuangan', 'analisis keuangan', 'insight keuangan', 'pandangan keuangan', 'gambaran keuangan', 'evaluasi keuangan', 'analisis kondisi keuangan', 'pemahaman keuangan', 'review keuangan', 'tinjauan keuangan']
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
            case 'next_month_prediction':
                return $this->predictNextMonthExpenses($userId);
            case 'date_filtered_data':
                return $this->getDateFilteredData($userId, $intent);
            case 'financial_health':
                return $this->calculateFinancialHealth($userId);
            case 'yearly_expense_income':
                return $this->calculateYearlyExpenseIncome($userId, $intent);
            case 'transaction_list':
                return $this->getTransactionList($userId, $intent);
            case 'savings_goals':
                return $this->getSavingsGoalsInfo($userId);
            case 'budget_info':
                return $this->getBudgetInfo($userId);
            case 'financial_insights':
                return $this->getFinancialInsights($userId);
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
    private function getGeneralResponse(?int $userId, string $question): array
    {
        // Get user's financial data to provide context
        $recentTransactions = collect([]); // Return empty collection if userId is null
        if ($userId !== null) {
            $recentTransactions = $this->transactionRepository->getAll($userId, [
                'limit' => 20,
                'start_date' => now()->subDays(30)->format('Y-m-d'),
                'end_date' => now()->format('Y-m-d')
            ]);
        }

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

        // Check if the question is asking for financial insights
        if (strpos($questionLower, 'wawasan') !== false || strpos($questionLower, 'insight') !== false ||
            strpos($questionLower, 'analisis') !== false || strpos($questionLower, 'pandangan') !== false) {

            if ($recentTransactions->count() > 0) {
                $insights = $this->generateFinancialInsights($userId);
                return [
                    'success' => true,
                    'answer' => $insights,
                    'intent' => ['type' => 'financial_insights']
                ];
            } else {
                return [
                    'success' => true,
                    'answer' => 'Saat ini Anda belum memiliki cukup data transaksi untuk memberikan wawasan keuangan. Silakan tambahkan beberapa transaksi untuk mendapatkan analisis yang lebih lengkap.',
                    'intent' => ['type' => 'no_data']
                ];
            }
        }

        // Check if the question is asking for financial health assessment
        if (strpos($questionLower, 'kesehatan') !== false || strpos($questionLower, 'cek keuangan') !== false ||
            strpos($questionLower, 'evaluasi keuangan') !== false || strpos($questionLower, 'peringkat keuangan') !== false) {

            if ($recentTransactions->count() > 0) {
                $healthAssessment = $this->calculateFinancialHealth($userId);
                return [
                    'success' => true,
                    'answer' => $healthAssessment,
                    'intent' => ['type' => 'financial_health']
                ];
            } else {
                return [
                    'success' => true,
                    'answer' => 'Saat ini Anda belum memiliki cukup data transaksi untuk menilai kesehatan keuangan. Silakan tambahkan beberapa transaksi untuk mendapatkan penilaian yang akurat.',
                    'intent' => ['type' => 'no_data']
                ];
            }
        }

        // Check if the question is asking for financial predictions
        if (strpos($questionLower, 'prediksi') !== false || strpos($questionLower, 'proyeksi') !== false ||
            strpos($questionLower, 'ramalan') !== false || strpos($questionLower, 'perkiraan') !== false) {

            if ($recentTransactions->count() > 0) {
                $prediction = $this->predictNextMonthExpenses($userId);
                return [
                    'success' => true,
                    'answer' => $prediction,
                    'intent' => ['type' => 'financial_prediction']
                ];
            } else {
                return [
                    'success' => true,
                    'answer' => 'Saat ini Anda belum memiliki cukup data historis untuk membuat prediksi keuangan. Silakan tambahkan beberapa transaksi untuk meningkatkan akurasi prediksi.',
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
     * Get financial insights for the user
     */
    private function getFinancialInsights(int $userId): string
    {
        return $this->generateFinancialInsights($userId);
    }

    /**
     * Save conversation to database for local chatbot
     */
    private function saveConversation(int $userId, string $question, string $answer, array $intent): void
    {
        try {
            // Only save if user is authenticated
            if ($userId !== null) {
                ChatbotConversation::create([
                    'user_id' => $userId,
                    'user_question' => $question,
                    'ai_response' => $answer,
                    'intent' => $intent,
                    'conversation_type' => 'financial'
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Failed to save chatbot conversation: ' . $e->getMessage());
        }
    }

    /**
     * Generate financial insights based on user's transaction data
     */
    private function generateFinancialInsights(int $userId): string
    {
        $sections = $this->generateIndividualInsightSections($userId);

        // Combine all sections into one comprehensive report
        $insights = "=== ANALISIS KEUANGAN PRIBADI ANDA ===\n\n";

        foreach ($sections as $section) {
            $insights .= $section . "\n";
        }

        $insights .= "\nCatatan: Analisis ini didasarkan pada data transaksi Anda selama 6 bulan terakhir. ";
        $insights .= "Untuk hasil yang lebih akurat, pastikan data transaksi Anda lengkap dan terkini.";

        return $insights;
    }

    /**
     * Generate individual insight sections that can be displayed separately
     */
    private function generateIndividualInsightSections(int $userId): array
    {
        // Get recent transactions (last 6 months for more comprehensive analysis)
        $sixMonthsAgo = now()->subMonths(6)->startOfMonth()->format('Y-m-d');
        $recentTransactions = $this->transactionRepository->getAll($userId, [
            'limit' => 1000,
            'start_date' => $sixMonthsAgo,
            'end_date' => now()->format('Y-m-d')
        ]);

        if ($recentTransactions->isEmpty()) {
            return ["Anda belum memiliki cukup data transaksi untuk memberikan wawasan keuangan. Silakan tambahkan beberapa transaksi untuk mendapatkan analisis yang lebih lengkap."];
        }

        // Calculate monthly totals
        $monthlyData = [];
        foreach ($recentTransactions as $transaction) {
            $monthYear = $transaction->date->format('Y-m');
            if (!isset($monthlyData[$monthYear])) {
                $monthlyData[$monthYear] = ['income' => 0, 'expense' => 0, 'transactions' => []];
            }

            if ($transaction->type === 'income') {
                $monthlyData[$monthYear]['income'] += $transaction->amount;
            } else {
                $monthlyData[$monthYear]['expense'] += $transaction->amount;
            }
            $monthlyData[$monthYear]['transactions'][] = $transaction;
        }

        // Sort by date
        ksort($monthlyData);

        // Calculate totals
        $totalIncome = 0;
        $totalExpense = 0;
        $categoryExpenses = [];
        $dailyExpenses = []; // Track daily spending patterns

        foreach ($recentTransactions as $transaction) {
            if ($transaction->type === 'income') {
                $totalIncome += $transaction->amount;
            } else {
                $totalExpense += $transaction->amount;

                // Group expenses by category
                $categoryName = $transaction->category ? $transaction->category->name : 'Umum';
                if (!isset($categoryExpenses[$categoryName])) {
                    $categoryExpenses[$categoryName] = 0;
                }
                $categoryExpenses[$categoryName] += $transaction->amount;

                // Track daily expenses for pattern analysis
                $day = $transaction->date->format('Y-m-d');
                if (!isset($dailyExpenses[$day])) {
                    $dailyExpenses[$day] = 0;
                }
                $dailyExpenses[$day] += $transaction->amount;
            }
        }

        // Find top expense categories
        arsort($categoryExpenses);
        $topCategories = array_slice($categoryExpenses, 0, 5, true); // Get top 5 instead of 3

        $sections = [];

        // Overall financial health
        $balance = $totalIncome - $totalExpense;
        if ($balance > 0) {
            $sections[] = "💰 KONDISI KEUANGAN SAAT INI:\nAnda memiliki surplus sebesar Rp " . number_format($balance, 0, ',', '.') . ". Ini menunjukkan manajemen keuangan yang baik dan disiplin finansial yang kuat. Dengan posisi keuangan yang positif ini, Anda memiliki ruang untuk mengejar tujuan finansial jangka panjang seperti investasi atau menambah tabungan.";
        } else {
            $sections[] = "⚠️ KONDISI KEUANGAN SAAT INI:\nAnda mengalami defisit sebesar Rp " . number_format(abs($balance), 0, ',', '.') . ". Ini berarti pengeluaran Anda melebihi pendapatan, yang merupakan sinyal penting untuk segera meninjau kembali pola pengeluaran Anda. Disarankan untuk segera mengidentifikasi dan mengurangi pengeluaran non-esensial.";
        }

        // Monthly trend analysis
        $months = array_keys($monthlyData);
        if (count($months) >= 2) {
            $latestMonth = end($months);
            $prevMonth = prev($months);

            if (isset($monthlyData[$prevMonth]) && isset($monthlyData[$latestMonth])) {
                $prevExpense = $monthlyData[$prevMonth]['expense'];
                $latestExpense = $monthlyData[$latestMonth]['expense'];

                if ($prevExpense > 0) {
                    $changePercent = (($latestExpense - $prevExpense) / $prevExpense) * 100;
                    if ($changePercent > 10) {
                        $sections[] = "📈 TREN PENGELOUARAN:\nPengeluaran Anda meningkat sebesar " . number_format(abs($changePercent), 2) . "% dari bulan sebelumnya. Kenaikan signifikan ini memerlukan evaluasi mendalam terhadap pengeluaran Anda. Periksa kembali apakah kenaikan ini disebabkan oleh pengeluaran esensial atau non-esensial. Jika disebabkan oleh pengeluaran non-esensial, pertimbangkan untuk menyesuaikan anggaran Anda.";
                    } elseif ($changePercent < -10) {
                        $sections[] = "📉 TREN PENGELOUARAN:\nPengeluaran Anda menurun sebesar " . number_format(abs($changePercent), 2) . "% dari bulan sebelumnya. Penurunan ini menunjukkan bahwa Anda sedang dalam jalur yang benar dalam mengelola keuangan. Pertahankan disiplin ini dan pertimbangkan untuk mengalihkan penghematan Anda ke instrumen investasi yang produktif.";
                    } else {
                        $sections[] = "📊 TREN PENGELOUARAN:\nPengeluaran Anda relatif stabil dibandingkan bulan sebelumnya. Stabilitas ini menunjukkan bahwa Anda memiliki kontrol yang baik terhadap pengeluaran Anda. Namun, tetap penting untuk secara berkala mengevaluasi apakah pengeluaran Anda sejalan dengan prioritas keuangan Anda.";
                    }
                }
            }
        }

        // Seasonal spending patterns
        $monthlyAvg = [];
        foreach ($monthlyData as $month => $data) {
            $monthNum = substr($month, 5, 2);
            if (!isset($monthlyAvg[$monthNum])) {
                $monthlyAvg[$monthNum] = [];
            }
            $monthlyAvg[$monthNum][] = $data['expense'];
        }

        $highestSpendingMonth = null;
        $highestAvg = 0;
        foreach ($monthlyAvg as $month => $expenses) {
            $avg = array_sum($expenses) / count($expenses);
            if ($avg > $highestAvg) {
                $highestAvg = $avg;
                $highestSpendingMonth = $month;
            }
        }

        if ($highestSpendingMonth) {
            $monthNames = [
                '01' => 'Januari', '02' => 'Februari', '03' => 'Maret', '04' => 'April',
                '05' => 'Mei', '06' => 'Juni', '07' => 'Juli', '08' => 'Agustus',
                '09' => 'September', '10' => 'Oktober', '11' => 'November', '12' => 'Desember'
            ];
            $sections[] = "📅 POLA PENGELOUARAN MUSIMAN:\nBerdasarkan data historis, bulan " . $monthNames[$highestSpendingMonth] . " cenderung menjadi bulan dengan pengeluaran tertinggi. Ini mungkin disebabkan oleh faktor-faktor seperti liburan, kebutuhan musiman, atau acara-acara khusus. Disarankan untuk mulai menyiapkan anggaran lebih besar di bulan ini dengan mempersiapkan dana cadangan beberapa bulan sebelumnya.";
        }

        // Top expense categories
        if (!empty($topCategories)) {
            $categorySection = "🏷️ KATEGORI PENGELOUARAN TERBESAR:\n";
            $rank = 1;
            foreach ($topCategories as $category => $amount) {
                $percentage = $totalExpense > 0 ? ($amount / $totalExpense) * 100 : 0;
                $categorySection .= "   {$rank}. {$category}: Rp " . number_format($amount, 0, ',', '.') . " (" . number_format($percentage, 2) . "% dari total pengeluaran)\n";
                $rank++;
            }

            // Analyze the top category
            $topCategory = key($topCategories);
            $topPercentage = current($topCategories) / $totalExpense * 100;
            if ($topPercentage > 30) {
                $categorySection .= "\n🔍 ANALISIS KATEGORI UTAMA:\nKategori {$topCategory} menyumbang lebih dari 30% dari total pengeluaran Anda, yang merupakan proporsi yang cukup besar. Pertimbangkan untuk mengevaluasi kembali pengeluaran dalam kategori ini dan cari cara untuk mengoptimalkannya tanpa mengorbankan kebutuhan pokok.";
            }

            $sections[] = $categorySection;
        }

        // Daily spending patterns
        if (!empty($dailyExpenses)) {
            $avgDailyExpense = array_sum($dailyExpenses) / count($dailyExpenses);
            $highSpendingDays = array_filter($dailyExpenses, function($amount) use ($avgDailyExpense) {
                return $amount > $avgDailyExpense * 1.5; // Days with 50% more spending than average
            });

            if (count($highSpendingDays) > 0) {
                $sections[] = "⏰ POLA PENGELOUARAN HARIAN:\nAnda cenderung mengeluarkan lebih banyak uang pada " . count($highSpendingDays) . " hari tertentu dalam sebulan. Identifikasi hari-hari ini untuk mengoptimalkan pengeluaran. Misalnya, jika pengeluaran tinggi terjadi di akhir pekan, pertimbangkan untuk membuat anggaran khusus untuk aktivitas akhir pekan.";
            }
        }

        // Savings rate analysis
        if ($totalIncome > 0) {
            $savingsRate = ($balance / $totalIncome) * 100;
            if ($savingsRate > 20) {
                $sections[] = "🏆 TINGKAT TABUNGAN:\nAnda memiliki tingkat tabungan sebesar " . number_format($savingsRate, 2) . "%. Ini merupakan rasio yang sangat baik dan menunjukkan disiplin keuangan yang kuat. Dengan tingkat tabungan ini, Anda berada di jalur yang benar menuju kebebasan finansial. Pertimbangkan untuk mengalokasikan sebagian tabungan Anda ke instrumen investasi yang sesuai dengan profil risiko Anda.";
            } elseif ($savingsRate > 10) {
                $sections[] = "🏆 TINGKAT TABUNGAN:\nAnda memiliki tingkat tabungan sebesar " . number_format($savingsRate, 2) . "%. Ini merupakan rasio yang cukup baik namun masih ada ruang untuk peningkatan. Usahakan untuk meningkatkan tabungan Anda hingga minimal 20% dari pendapatan untuk memperkuat posisi keuangan jangka panjang Anda.";
            } elseif ($savingsRate > 0) {
                $sections[] = "🏆 TINGKAT TABUNGAN:\nAnda memiliki tingkat tabungan sebesar " . number_format($savingsRate, 2) . "%. Ini merupakan awal yang baik namun masih jauh dari rekomendasi keuangan umum sebesar 10-20% dari pendapatan. Disarankan untuk meningkatkan tabungan minimal hingga 10-20% dari pendapatan Anda.";
            } else {
                $sections[] = "🏆 TINGKAT TABUNGAN:\nAnda belum memiliki tabungan karena pengeluaran melebihi pendapatan. Ini adalah situasi yang perlu segera ditangani. Prioritaskan pengurangan pengeluaran non-esensial dan cari peluang untuk meningkatkan pendapatan. Tanpa tabungan, Anda rentan terhadap situasi keuangan darurat.";
            }
        }

        // Emergency fund calculation
        $monthlyExpenseAvg = count($monthlyData) > 0 ? array_sum(array_column($monthlyData, 'expense')) / count($monthlyData) : 0;
        $recommendedEmergencyFund = $monthlyExpenseAvg * 6; // 6 months of expenses
        $emergencyFundStatus = $balance >= $recommendedEmergencyFund ? "TERSEDIA" : "BELUM MEMADAI";

        $sections[] = "🛡️ DANA DARURAT:\nDana darurat idealnya sebesar Rp " . number_format($recommendedEmergencyFund, 0, ',', '.') . " (6x rata-rata pengeluaran bulanan). Dana darurat ini sangat penting sebagai buffer untuk situasi tak terduga seperti kehilangan pekerjaan, biaya medis, atau perbaikan tak terduga. Status: " . $emergencyFundStatus . ". Jika dana darurat belum memadai, prioritaskan pembentukan dana ini sebelum mengejar tujuan investasi lainnya.";

        // Predictive analysis
        if (count($monthlyData) >= 3) {
            // Calculate average monthly change in expenses
            $expenseChanges = [];
            $monthsList = array_values($monthlyData);
            for ($i = 1; $i < count($monthsList); $i++) {
                if ($monthsList[$i-1]['expense'] > 0) {
                    $change = (($monthsList[$i]['expense'] - $monthsList[$i-1]['expense']) / $monthsList[$i-1]['expense']) * 100;
                    $expenseChanges[] = $change;
                }
            }

            if (!empty($expenseChanges)) {
                $avgChange = array_sum($expenseChanges) / count($expenseChanges);
                if ($avgChange > 5) {
                    $sections[] = "🔮 ANALISIS PREDIKTIF:\nBerdasarkan tren historis, pengeluaran Anda diperkirakan akan meningkat sekitar " . number_format($avgChange, 2) . "% per bulan. Ini menunjukkan adanya potensi peningkatan pengeluaran yang signifikan di masa depan. Pertimbangkan untuk menyesuaikan anggaran Anda dan menyiapkan strategi untuk mengelola potensi kenaikan ini. Evaluasi kembali kebiasaan belanja Anda dan identifikasi area yang bisa dioptimalkan.";
                } elseif ($avgChange < -5) {
                    $sections[] = "🔮 ANALISIS PREDIKTIF:\nBerdasarkan tren historis, pengeluaran Anda diperkirakan akan menurun sekitar " . number_format(abs($avgChange), 2) . "% per bulan. Ini menunjukkan bahwa Anda sedang dalam jalur yang semakin baik dalam pengelolaan keuangan. Manfaatkan penurunan ini untuk meningkatkan tabungan atau alokasikan ke investasi produktif.";
                } else {
                    $sections[] = "🔮 ANALISIS PREDIKTIF:\nPengeluaran Anda diperkirakan akan relatif stabil dalam beberapa bulan ke depan. Ini memberikan kepastian dalam perencanaan keuangan jangka pendek. Gunakan stabilitas ini untuk fokus pada tujuan keuangan jangka menengah dan panjang seperti pembelian aset atau investasi.";
                }
            }
        }

        // Personalized recommendations
        $recommendationSection = "💡 REKOMENDASI PRIBADI:\n";
        if ($balance <= 0) {
            $recommendationSection .= "- Prioritaskan pengurangan pengeluaran non-esensial untuk mencapai titik impas\n";
        }

        if (!empty($topCategories)) {
            $topCategory = key($topCategories);
            if (strpos(strtolower($topCategory), 'makan') !== false) {
                $recommendationSection .= "- Pertimbangkan untuk menyiapkan makanan sendiri untuk mengurangi biaya makanan. Membawa bekal dari rumah bisa menghemat hingga 60-70% dari biaya makan harian.\n";
            } elseif (strpos(strtolower($topCategory), 'transportasi') !== false) {
                $recommendationSection .= "- Evaluasi opsi transportasi yang lebih hemat biaya (misalnya carpooling, kendaraan umum, atau kereta api). Pertimbangkan juga untuk mengatur rute perjalanan Anda secara efisien untuk mengurangi biaya transportasi.\n";
            } elseif (strpos(strtolower($topCategory), 'hiburan') !== false) {
                $recommendationSection .= "- Batasi pengeluaran hiburan untuk meningkatkan tabungan. Pertimbangkan aktivitas hiburan gratis atau murah seperti berjalan-jalan di taman, bermain di rumah, atau acara komunitas.\n";
            } elseif (strpos(strtolower($topCategory), 'tagih') !== false) {
                $recommendationSection .= "- Tinjau kembali langganan atau cicilan yang mungkin bisa dioptimalkan. Periksa apakah ada langganan yang tidak Anda gunakan secara maksimal dan pertimbangkan untuk membatalkannya.\n";
            }
        }

        $recommendationSection .= "- Buat anggaran bulanan berdasarkan pola pengeluaran historis Anda\n";
        $recommendationSection .= "- Siapkan dana darurat sesuai rekomendasi di atas\n";
        $recommendationSection .= "- Evaluasi investasi untuk meningkatkan pendapatan pasif\n";
        $recommendationSection .= "- Tinjau dan bandingkan harga sebelum melakukan pembelian besar\n";
        $recommendationSection .= "- Gunakan aplikasi pelacak keuangan untuk pemantauan yang lebih ketat\n";

        $sections[] = $recommendationSection;

        return $sections;
    }

    /**
     * Get a specific insight section by type
     */
    private function getSpecificInsight(int $userId, string $sectionType): string
    {
        $sections = $this->generateIndividualInsightSections($userId);

        switch ($sectionType) {
            case 'financial_health':
                return $this->filterSectionByEmoji($sections, '💰', '⚠️');
            case 'trend_analysis':
                return $this->filterSectionByEmoji($sections, '📈', '📉', '📊');
            case 'seasonal_pattern':
                return $this->filterSectionByEmoji($sections, '📅');
            case 'expense_categories':
                return $this->filterSectionByEmoji($sections, '🏷️', '🔍');
            case 'daily_pattern':
                return $this->filterSectionByEmoji($sections, '⏰');
            case 'savings_rate':
                return $this->filterSectionByEmoji($sections, '🏆');
            case 'emergency_fund':
                return $this->filterSectionByEmoji($sections, '🛡️');
            case 'predictive_analysis':
                return $this->filterSectionByEmoji($sections, '🔮');
            case 'recommendations':
                return $this->filterSectionByEmoji($sections, '💡');
            default:
                return implode("\n\n", $sections);
        }
    }

    /**
     * Helper function to filter sections by emoji
     */
    private function filterSectionByEmoji(array $sections, string ...$emojis): string
    {
        foreach ($sections as $section) {
            foreach ($emojis as $emoji) {
                if (str_starts_with($section, $emoji)) {
                    return $section;
                }
            }
        }

        return "Informasi untuk bagian ini tidak tersedia.";
    }

    /**
     * Generate predictive analysis for next month based on historical patterns
     */
    private function predictNextMonthExpenses(int $userId): string
    {
        // Get historical data for the past few months
        $threeMonthsAgo = now()->subMonths(3)->startOfMonth()->format('Y-m-d');
        $historicalTransactions = $this->transactionRepository->getAll($userId, [
            'limit' => 1000,
            'start_date' => $threeMonthsAgo,
            'end_date' => now()->format('Y-m-d'),
            'type' => 'expense'
        ]);

        if ($historicalTransactions->isEmpty()) {
            return "Belum ada cukup data historis untuk membuat prediksi pengeluaran bulan depan. Silakan tambahkan lebih banyak transaksi untuk meningkatkan akurasi prediksi.";
        }

        // Group expenses by category for the past 3 months
        $categoryTotals = [];
        $monthCounts = []; // Count how many months each category appeared

        foreach ($historicalTransactions as $transaction) {
            $monthYear = $transaction->date->format('Y-m');
            $categoryName = $transaction->category ? $transaction->category->name : 'Umum';

            if (!isset($categoryTotals[$categoryName])) {
                $categoryTotals[$categoryName] = 0;
            }
            $categoryTotals[$categoryName] += $transaction->amount;

            // Track months where category appeared
            if (!isset($monthCounts[$categoryName])) {
                $monthCounts[$categoryName] = [];
            }
            if (!in_array($monthYear, $monthCounts[$categoryName])) {
                $monthCounts[$categoryName][] = $monthYear;
            }
        }

        // Calculate average monthly expense per category
        $avgCategoryExpenses = [];
        foreach ($categoryTotals as $category => $total) {
            $avgCategoryExpenses[$category] = $total / count($monthCounts[$category]);
        }

        // Predict next month's expenses based on average
        $nextMonth = now()->addMonth();
        $predictedExpenses = [];
        $totalPredicted = 0;

        foreach ($avgCategoryExpenses as $category => $avgAmount) {
            $predictedExpenses[$category] = $avgAmount;
            $totalPredicted += $avgAmount;
        }

        // Get user's income pattern to determine if predicted expenses are sustainable
        $incomeTransactions = $this->transactionRepository->getAll($userId, [
            'limit' => 1000,
            'start_date' => $threeMonthsAgo,
            'end_date' => now()->format('Y-m-d'),
            'type' => 'income'
        ]);

        $totalIncome = 0;
        $incomeMonths = [];
        foreach ($incomeTransactions as $transaction) {
            $monthYear = $transaction->date->format('Y-m');
            $totalIncome += $transaction->amount;

            if (!in_array($monthYear, $incomeMonths)) {
                $incomeMonths[] = $monthYear;
            }
        }

        $avgMonthlyIncome = count($incomeMonths) > 0 ? $totalIncome / count($incomeMonths) : 0;
        $sustainability = $totalPredicted <= $avgMonthlyIncome ? "cukup" : "melebihi";

        // Prepare prediction response
        $prediction = "📊 PREDIKSI KEUANGAN BULAN DEPAN ({$nextMonth->format('F Y')}):\n\n";
        $prediction .= "Berdasarkan pola historis pengeluaran Anda, berikut perkiraan pengeluaran bulan depan:\n\n";

        arsort($predictedExpenses); // Sort by highest expense
        foreach ($predictedExpenses as $category => $amount) {
            $prediction .= "- {$category}: Rp " . number_format($amount, 0, ',', '.') . "\n";
        }

        $prediction .= "\n💰 Total prediksi pengeluaran: Rp " . number_format($totalPredicted, 0, ',', '.') . "\n";
        $prediction .= "💰 Rata-rata pendapatan bulanan: Rp " . number_format($avgMonthlyIncome, 0, ',', '.') . "\n";
        $prediction .= "Status keuangan: Pengeluaran bulan depan diperkirakan " . $sustainability . " dari pendapatan.\n\n";

        // Add recommendations based on prediction
        $prediction .= "💡 REKOMENDASI:\n";
        if ($sustainability === "melebihi") {
            $prediction .= "- Pertimbangkan untuk mengurangi pengeluaran di kategori tertentu\n";
            $prediction .= "- Evaluasi kembali anggaran bulan depan\n";
        } else {
            $prediction .= "- Anda memiliki keseimbangan keuangan yang baik\n";
            $prediction .= "- Pertimbangkan untuk menabung sebagian dari sisa anggaran\n";
        }

        $prediction .= "- Siapkan dana darurat untuk mengantisipasi pengeluaran tak terduga\n";
        $prediction .= "- Bandingkan prediksi ini dengan rencana anggaran Anda\n";

        return $prediction;
    }

    /**
     * Get data filtered by specific date range based on user's question
     */
    private function getDateFilteredData(int $userId, array $intent): string
    {
        // Extract date information from intent
        $year = $intent['year'] ?? null;
        $time_period = $intent['time_period'] ?? null;

        // If year is specified, get data for that year
        if ($year) {
            $startDate = \Carbon\Carbon::createFromDate($year, 1, 1)->startOfDay();
            $endDate = \Carbon\Carbon::createFromDate($year, 12, 31)->endOfDay();

            // If time_period contains specific month, narrow down to that month
            if ($time_period) {
                $monthNumber = $this->getMonthNumberFromName($time_period);
                if ($monthNumber) {
                    $startDate = \Carbon\Carbon::createFromDate($year, $monthNumber, 1)->startOfMonth();
                    $endDate = \Carbon\Carbon::createFromDate($year, $monthNumber, 1)->endOfMonth();
                }
            }

            $incomeQuery = \App\Models\Transaction::where('user_id', $userId)
                ->where('type', 'income')
                ->whereDate('date', '>=', $startDate->format('Y-m-d'))
                ->whereDate('date', '<=', $endDate->format('Y-m-d'));

            $expenseQuery = \App\Models\Transaction::where('user_id', $userId)
                ->where('type', 'expense')
                ->whereDate('date', '>=', $startDate->format('Y-m-d'))
                ->whereDate('date', '<=', $endDate->format('Y-m-d'));

            $income = $incomeQuery->sum('amount');
            $expense = $expenseQuery->sum('amount');

            // Get detailed transactions
            $transactions = \App\Models\Transaction::where('user_id', $userId)
                ->whereDate('date', '>=', $startDate->format('Y-m-d'))
                ->whereDate('date', '<=', $endDate->format('Y-m-d'))
                ->with(['category'])
                ->orderBy('date', 'desc')
                ->get();

            if ($transactions->isEmpty()) {
                return "Tidak ditemukan data transaksi untuk periode {$startDate->format('F Y')}. Silakan tambahkan transaksi untuk periode tersebut.";
            }

            $result = "📊 DATA KEUANGAN UNTUK PERIODE {$startDate->format('F Y')}:\n\n";
            $result .= "Total Pemasukan: Rp " . number_format($income, 0, ',', '.') . "\n";
            $result .= "Total Pengeluaran: Rp " . number_format($expense, 0, ',', '.') . "\n";
            $result .= "Saldo: Rp " . number_format($income - $expense, 0, ',', '.') . "\n\n";

            $result .= "📋 TRANSAKSI RINCIAN:\n";
            foreach ($transactions as $transaction) {
                $categoryName = $transaction->category ? $transaction->category->name : 'Umum';
                $typeText = $transaction->type === 'income' ? 'Pemasukan' : 'Pengeluaran';
                $result .= "- {$typeText}: Rp " . number_format($transaction->amount, 0, ',', '.') .
                          " ({$transaction->description} - {$categoryName}) pada " .
                          $transaction->date->format('j F Y') . "\n";
            }

            return $result;
        }

        return "Tidak dapat menemukan informasi tanggal yang spesifik dalam permintaan Anda.";
    }

    /**
     * Helper function to get month number from month name
     */
    private function getMonthNumberFromName(string $monthName): ?int
    {
        $monthName = strtolower(trim($monthName));
        $months = [
            'januari' => 1, 'februari' => 2, 'maret' => 3, 'april' => 4,
            'mei' => 5, 'juni' => 6, 'juli' => 7, 'agustus' => 8,
            'september' => 9, 'oktober' => 10, 'november' => 11, 'desember' => 12
        ];

        foreach ($months as $name => $number) {
            if (strpos($monthName, $name) !== false) {
                return $number;
            }
        }

        return null;
    }

    /**
     * Calculate financial health based on user's transaction data
     */
    private function calculateFinancialHealth(int $userId): string
    {
        // Get recent transactions (last 6 months for more comprehensive analysis)
        $sixMonthsAgo = now()->subMonths(6)->startOfMonth()->format('Y-m-d');
        $recentTransactions = $this->transactionRepository->getAll($userId, [
            'limit' => 1000,
            'start_date' => $sixMonthsAgo,
            'end_date' => now()->format('Y-m-d')
        ]);

        if ($recentTransactions->isEmpty()) {
            return "Anda belum memiliki cukup data transaksi untuk menilai kesehatan keuangan. Silakan tambahkan beberapa transaksi untuk mendapatkan penilaian yang akurat.";
        }

        // Calculate monthly totals
        $monthlyData = [];
        foreach ($recentTransactions as $transaction) {
            $monthYear = $transaction->date->format('Y-m');
            if (!isset($monthlyData[$monthYear])) {
                $monthlyData[$monthYear] = ['income' => 0, 'expense' => 0, 'transactions' => []];
            }

            if ($transaction->type === 'income') {
                $monthlyData[$monthYear]['income'] += $transaction->amount;
            } else {
                $monthlyData[$monthYear]['expense'] += $transaction->amount;
            }
            $monthlyData[$monthYear]['transactions'][] = $transaction;
        }

        // Sort by date
        ksort($monthlyData);

        // Calculate totals
        $totalIncome = 0;
        $totalExpense = 0;
        $categoryExpenses = [];
        $dailyExpenses = []; // Track daily spending patterns

        foreach ($recentTransactions as $transaction) {
            if ($transaction->type === 'income') {
                $totalIncome += $transaction->amount;
            } else {
                $totalExpense += $transaction->amount;

                // Group expenses by category
                $categoryName = $transaction->category ? $transaction->category->name : 'Umum';
                if (!isset($categoryExpenses[$categoryName])) {
                    $categoryExpenses[$categoryName] = 0;
                }
                $categoryExpenses[$categoryName] += $transaction->amount;

                // Track daily expenses for pattern analysis
                $day = $transaction->date->format('Y-m-d');
                if (!isset($dailyExpenses[$day])) {
                    $dailyExpenses[$day] = 0;
                }
                $dailyExpenses[$day] += $transaction->amount;
            }
        }

        // Find top expense categories
        arsort($categoryExpenses);
        $topCategories = array_slice($categoryExpenses, 0, 5, true); // Get top 5 instead of 3

        // Prepare health assessment
        $assessment = "=== PENILAIAN KESEHATAN KEUANGAN ANDA ===\n\n";

        // Overall financial health
        $balance = $totalIncome - $totalExpense;
        if ($balance > 0) {
            $assessment .= "💰 KONDISI KEUANGAN SAAT INI:\n";
            $assessment .= "Anda memiliki surplus sebesar Rp " . number_format($balance, 0, ',', '.') . ". Ini menunjukkan manajemen keuangan yang baik dan disiplin finansial yang kuat. ";
            $assessment .= "Dengan posisi keuangan yang positif ini, Anda memiliki ruang untuk mengejar tujuan finansial jangka panjang seperti investasi atau menambah tabungan.\n\n";
        } else {
            $assessment .= "⚠️ KONDISI KEUANGAN SAAT INI:\n";
            $assessment .= "Anda mengalami defisit sebesar Rp " . number_format(abs($balance), 0, ',', '.') . ". Ini berarti pengeluaran Anda melebihi pendapatan, ";
            $assessment .= "yang merupakan sinyal penting untuk segera meninjau kembali pola pengeluaran Anda. Disarankan untuk segera mengidentifikasi dan mengurangi pengeluaran non-esensial.\n\n";
        }

        // Monthly trend analysis
        $months = array_keys($monthlyData);
        if (count($months) >= 2) {
            $latestMonth = end($months);
            $prevMonth = prev($months);

            if (isset($monthlyData[$prevMonth]) && isset($monthlyData[$latestMonth])) {
                $prevExpense = $monthlyData[$prevMonth]['expense'];
                $latestExpense = $monthlyData[$latestMonth]['expense'];

                if ($prevExpense > 0) {
                    $changePercent = (($latestExpense - $prevExpense) / $prevExpense) * 100;
                    if ($changePercent > 10) {
                        $assessment .= "📈 TREN PENGELOUARAN:\n";
                        $assessment .= "Pengeluaran Anda meningkat sebesar " . number_format(abs($changePercent), 2) . "% dari bulan sebelumnya. ";
                        $assessment .= "Kenaikan signifikan ini memerlukan evaluasi mendalam terhadap pengeluaran Anda. ";
                        $assessment .= "Periksa kembali apakah kenaikan ini disebabkan oleh pengeluaran esensial atau non-esensial. ";
                        $assessment .= "Jika disebabkan oleh pengeluaran non-esensial, pertimbangkan untuk menyesuaikan anggaran Anda.\n\n";
                    } elseif ($changePercent < -10) {
                        $assessment .= "📉 TREN PENGELOUARAN:\n";
                        $assessment .= "Pengeluaran Anda menurun sebesar " . number_format(abs($changePercent), 2) . "% dari bulan sebelumnya. ";
                        $assessment .= "Penurunan ini menunjukkan bahwa Anda sedang dalam jalur yang benar dalam mengelola keuangan. ";
                        $assessment .= "Pertahankan disiplin ini dan pertimbangkan untuk mengalihkan penghematan Anda ke instrumen investasi yang produktif.\n\n";
                    } else {
                        $assessment .= "📊 TREN PENGELOUARAN:\n";
                        $assessment .= "Pengeluaran Anda relatif stabil dibandingkan bulan sebelumnya. ";
                        $assessment .= "Stabilitas ini menunjukkan bahwa Anda memiliki kontrol yang baik terhadap pengeluaran Anda. ";
                        $assessment .= "Namun, tetap penting untuk secara berkala mengevaluasi apakah pengeluaran Anda sejalan dengan prioritas keuangan Anda.\n\n";
                    }
                }
            }
        }

        // Top expense categories
        if (!empty($topCategories)) {
            $assessment .= "🏷️ KATEGORI PENGELOUARAN TERBESAR:\n";
            $rank = 1;
            foreach ($topCategories as $category => $amount) {
                $percentage = $totalExpense > 0 ? ($amount / $totalExpense) * 100 : 0;
                $assessment .= "   {$rank}. {$category}: Rp " . number_format($amount, 0, ',', '.') . " (" . number_format($percentage, 2) . "% dari total pengeluaran)\n";
                $rank++;
            }
            $assessment .= "\n";

            // Analyze the top category
            $topCategory = key($topCategories);
            $topPercentage = current($topCategories) / $totalExpense * 100;
            if ($topPercentage > 30) {
                $assessment .= "🔍 ANALISIS KATEGORI UTAMA:\n";
                $assessment .= "Kategori {$topCategory} menyumbang lebih dari 30% dari total pengeluaran Anda, ";
                $assessment .= "yang merupakan proporsi yang cukup besar. Pertimbangkan untuk mengevaluasi kembali pengeluaran dalam kategori ini ";
                $assessment .= "dan cari cara untuk mengoptimalkannya tanpa mengorbankan kebutuhan pokok.\n\n";
            }
        }

        // Savings rate analysis
        if ($totalIncome > 0) {
            $savingsRate = ($balance / $totalIncome) * 100;
            $assessment .= "🏆 TINGKAT TABUNGAN:\n";
            if ($savingsRate > 20) {
                $assessment .= "Anda memiliki tingkat tabungan sebesar " . number_format($savingsRate, 2) . "%. Ini merupakan rasio yang sangat baik ";
                $assessment .= "dan menunjukkan disiplin keuangan yang kuat. Dengan tingkat tabungan ini, Anda berada di jalur yang benar menuju ";
                $assessment .= "kebebasan finansial. Pertimbangkan untuk mengalokasikan sebagian tabungan Anda ke instrumen investasi yang sesuai ";
                $assessment .= "dengan profil risiko Anda.\n\n";
            } elseif ($savingsRate > 10) {
                $assessment .= "Anda memiliki tingkat tabungan sebesar " . number_format($savingsRate, 2) . "%. Ini merupakan rasio yang cukup baik ";
                $assessment .= "namun masih ada ruang untuk peningkatan. Usahakan untuk meningkatkan tabungan Anda hingga minimal 20% dari pendapatan ";
                $assessment .= "untuk memperkuat posisi keuangan jangka panjang Anda.\n\n";
            } elseif ($savingsRate > 0) {
                $assessment .= "Anda memiliki tingkat tabungan sebesar " . number_format($savingsRate, 2) . "%. Ini merupakan awal yang baik ";
                $assessment .= "namun masih jauh dari rekomendasi keuangan umum sebesar 10-20% dari pendapatan. Disarankan untuk meningkatkan ";
                $assessment .= "tabungan minimal hingga 10-20% dari pendapatan Anda.\n\n";
            } else {
                $assessment .= "Anda belum memiliki tabungan karena pengeluaran melebihi pendapatan. Ini adalah situasi yang perlu segera ditangani. ";
                $assessment .= "Prioritaskan pengurangan pengeluaran non-esensial dan cari peluang untuk meningkatkan pendapatan. ";
                $assessment .= "Tanpa tabungan, Anda rentan terhadap situasi keuangan darurat.\n\n";
            }
        }

        // Emergency fund calculation
        $monthlyExpenseAvg = count($monthlyData) > 0 ? array_sum(array_column($monthlyData, 'expense')) / count($monthlyData) : 0;
        $recommendedEmergencyFund = $monthlyExpenseAvg * 6; // 6 months of expenses
        $emergencyFundStatus = $balance >= $recommendedEmergencyFund ? "TERSEDIA" : "BELUM MEMADAI";

        $assessment .= "🛡️ DANA DARURAT:\n";
        $assessment .= "Dana darurat idealnya sebesar Rp " . number_format($recommendedEmergencyFund, 0, ',', '.') . " ";
        $assessment .= "(6x rata-rata pengeluaran bulanan). Dana darurat ini sangat penting sebagai buffer untuk situasi tak terduga ";
        $assessment .= "seperti kehilangan pekerjaan, biaya medis, atau perbaikan tak terduga. Status: " . $emergencyFundStatus . ". ";
        $assessment .= "Jika dana darurat belum memadai, prioritaskan pembentukan dana ini sebelum mengejar tujuan investasi lainnya.\n\n";

        // Predictive analysis
        $assessment .= "🔮 ANALISIS PREDIKTIF:\n";
        if (count($monthlyData) >= 3) {
            // Calculate average monthly change in expenses
            $expenseChanges = [];
            $monthsList = array_values($monthlyData);
            for ($i = 1; $i < count($monthsList); $i++) {
                if ($monthsList[$i-1]['expense'] > 0) {
                    $change = (($monthsList[$i]['expense'] - $monthsList[$i-1]['expense']) / $monthsList[$i-1]['expense']) * 100;
                    $expenseChanges[] = $change;
                }
            }

            if (!empty($expenseChanges)) {
                $avgChange = array_sum($expenseChanges) / count($expenseChanges);
                if ($avgChange > 5) {
                    $assessment .= "Berdasarkan tren historis, pengeluaran Anda diperkirakan akan meningkat sekitar " . number_format($avgChange, 2) . "% ";
                    $assessment .= "per bulan. Ini menunjukkan adanya potensi peningkatan pengeluaran yang signifikan di masa depan. ";
                    $assessment .= "Pertimbangkan untuk menyesuaikan anggaran Anda dan menyiapkan strategi untuk mengelola potensi kenaikan ini. ";
                    $assessment .= "Evaluasi kembali kebiasaan belanja Anda dan identifikasi area yang bisa dioptimalkan.\n\n";
                } elseif ($avgChange < -5) {
                    $assessment .= "Berdasarkan tren historis, pengeluaran Anda diperkirakan akan menurun sekitar " . number_format(abs($avgChange), 2) . "% ";
                    $assessment .= "per bulan. Ini menunjukkan bahwa Anda sedang dalam jalur yang semakin baik dalam pengelolaan keuangan. ";
                    $assessment .= "Manfaatkan penurunan ini untuk meningkatkan tabungan atau alokasikan ke investasi produktif.\n\n";
                } else {
                    $assessment .= "Pengeluaran Anda diperkirakan akan relatif stabil dalam beberapa bulan ke depan. ";
                    $assessment .= "Ini memberikan kepastian dalam perencanaan keuangan jangka pendek. Gunakan stabilitas ini untuk fokus ";
                    $assessment .= "pada tujuan keuangan jangka menengah dan panjang seperti pembelian aset atau investasi.\n\n";
                }
            }
        }

        // Personalized recommendations
        $assessment .= "💡 REKOMENDASI PRIBADI:\n";
        if ($balance <= 0) {
            $assessment .= "- Prioritaskan pengurangan pengeluaran non-esensial untuk mencapai titik impas\n";
        }

        if (!empty($topCategories)) {
            $topCategory = key($topCategories);
            if (strpos(strtolower($topCategory), 'makan') !== false) {
                $assessment .= "- Pertimbangkan untuk menyiapkan makanan sendiri untuk mengurangi biaya makanan. ";
                $assessment .= "Membawa bekal dari rumah bisa menghemat hingga 60-70% dari biaya makan harian.\n";
            } elseif (strpos(strtolower($topCategory), 'transportasi') !== false) {
                $assessment .= "- Evaluasi opsi transportasi yang lebih hemat biaya (misalnya carpooling, kendaraan umum, atau kereta api). ";
                $assessment .= "Pertimbangkan juga untuk mengatur rute perjalanan Anda secara efisien untuk mengurangi biaya transportasi.\n";
            } elseif (strpos(strtolower($topCategory), 'hiburan') !== false) {
                $assessment .= "- Batasi pengeluaran hiburan untuk meningkatkan tabungan. ";
                $assessment .= "Pertimbangkan aktivitas hiburan gratis atau murah seperti berjalan-jalan di taman, bermain di rumah, atau acara komunitas.\n";
            } elseif (strpos(strtolower($topCategory), 'tagih') !== false) {
                $assessment .= "- Tinjau kembali langganan atau cicilan yang mungkin bisa dioptimalkan. ";
                $assessment .= "Periksa apakah ada langganan yang tidak Anda gunakan secara maksimal dan pertimbangkan untuk membatalkannya.\n";
            }
        }

        $assessment .= "- Buat anggaran bulanan berdasarkan pola pengeluaran historis Anda\n";
        $assessment .= "- Siapkan dana darurat sesuai rekomendasi di atas\n";
        $assessment .= "- Evaluasi investasi untuk meningkatkan pendapatan pasif\n";
        $assessment .= "- Tinjau dan bandingkan harga sebelum melakukan pembelian besar\n";
        $assessment .= "- Gunakan aplikasi pelacak keuangan untuk pemantauan yang lebih ketat\n";

        $assessment .= "\nCatatan: Penilaian ini didasarkan pada data transaksi Anda selama 6 bulan terakhir. ";
        $assessment .= "Untuk hasil yang lebih akurat, pastikan data transaksi Anda lengkap dan terkini.";

        return $assessment;
    }
}