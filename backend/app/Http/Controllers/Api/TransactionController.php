<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreTransactionRequest;
use App\Http\Requests\UpdateTransactionRequest;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class TransactionController extends BaseController
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        
        // Check if user has admin role
        if ($user->hasRole('admin')) {
            $transactions = Transaction::with(['user', 'category'])->paginate(10);
        } else {
            $transactions = $user->transactions()->with('category')->paginate(10);
        }

        return $this->sendResponse($transactions, 'Transactions retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreTransactionRequest $request)
    {
        $user = Auth::user();
        $input = $request->validated();
        $input['user_id'] = $user->id;

        $transaction = Transaction::create($input);

        return $this->sendResponse($transaction, 'Transaction created successfully.', 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Transaction $transaction)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the transaction
        if (!$user->hasRole('admin') && $transaction->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        return $this->sendResponse($transaction->load('category'), 'Transaction retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateTransactionRequest $request, Transaction $transaction)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the transaction
        if (!$user->hasRole('admin') && $transaction->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $transaction->update($request->validated());

        return $this->sendResponse($transaction->load('category'), 'Transaction updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Transaction $transaction)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the transaction
        if (!$user->hasRole('admin') && $transaction->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $transaction->delete();

        return $this->sendResponse([], 'Transaction deleted successfully.');
    }

    /**
     * Get financial summary by month and year
     */
    public function getFinancialSummary(Request $request)
    {
        $user = Auth::user();
        $year = $request->input('year', date('Y'));
        $month = $request->input('month', date('m'));

        // Calculate monthly income and expense
        $transactions = $user->transactions()
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->select('type', DB::raw('SUM(amount) as total'))
            ->groupBy('type')
            ->get();

        $totalIncome = 0;
        $totalExpense = 0;

        foreach ($transactions as $transaction) {
            if ($transaction->type === 'income') {
                $totalIncome = $transaction->total;
            } else {
                $totalExpense = $transaction->total;
            }
        }

        // Calculate total saving for the month
        $totalSaving = $user->savings()
            ->whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->sum('current_amount');

        // Calculate net total
        $netTotal = $totalIncome - $totalExpense;

        $financialSummary = [
            'month' => $month,
            'year' => $year,
            'total_income' => (float)$totalIncome,
            'total_expense' => (float)$totalExpense,
            'net_total' => (float)$netTotal,
            'total_saving' => (float)$totalSaving,
        ];

        return $this->sendResponse($financialSummary, 'Financial summary retrieved successfully.');
    }

    /**
     * Get financial summary for multiple months
     */
    public function getMonthlyFinancialData(Request $request)
    {
        $user = Auth::user();
        $year = $request->input('year', date('Y'));

        // Get financial summary for current and next month
        $currentMonth = date('m');
        $nextMonth = date('m', strtotime('+1 month'));
        $currentYear = $year;
        $nextYear = $year;

        if ($currentMonth == 12) {
            $nextYear = $year + 1;
            $nextMonth = '01';
        }

        // Get data for current month
        $currentData = $this->calculateMonthlyData($user, $currentYear, $currentMonth);

        // Get data for next month
        $nextData = $this->calculateMonthlyData($user, $nextYear, $nextMonth);

        // Get all monthly data for the year
        $monthlyData = [];
        for ($i = 1; $i <= 12; $i++) {
            $monthData = $this->calculateMonthlyData($user, $year, str_pad($i, 2, '0', STR_PAD_LEFT));
            $monthlyData[] = $monthData;
        }

        $response = [
            'monthly_data' => $monthlyData,
            'current_month' => $currentData,
            'next_month' => $nextData,
        ];

        return $this->sendResponse($response, 'Monthly financial data retrieved successfully.');
    }

    private function calculateMonthlyData($user, $year, $month)
    {
        // Calculate monthly income and expense
        $transactions = $user->transactions()
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->select('type', DB::raw('SUM(amount) as total'))
            ->groupBy('type')
            ->get();

        $totalIncome = 0;
        $totalExpense = 0;

        foreach ($transactions as $transaction) {
            if ($transaction->type === 'income') {
                $totalIncome = $transaction->total;
            } else {
                $totalExpense = $transaction->total;
            }
        }

        // Calculate total saving for the month
        $totalSaving = $user->savings()
            ->whereYear('created_at', $year)
            ->whereMonth('created_at', $month)
            ->sum('current_amount');

        // Calculate net total
        $netTotal = $totalIncome - $totalExpense;

        return [
            'month' => $month,
            'year' => $year,
            'total_income' => (float)$totalIncome,
            'total_expense' => (float)$totalExpense,
            'net_total' => (float)$netTotal,
            'total_saving' => (float)$totalSaving,
        ];
    }
}
