<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\SelfTestController;
use App\Http\Controllers\Api\FinancialChatbotController;
use App\Http\Controllers\Api\OllamaController;
use App\Http\Controllers\Api\V1\BudgetController;
use App\Http\Controllers\Api\V1\SavingsGoalController;
use App\Http\Controllers\Api\V1\BillReminderController;
use App\Http\Controllers\Api\V1\FinancialReportController;
use App\Http\Controllers\Api\V1\FinancialAnalyticsController;

Route::get('/ping', function () {
    return response()->json(['status' => 'ok']);
});


// Public routes
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Protected routes
Route::middleware(['auth:sanctum'])->group(function () {
    // Auth routes
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/profile', [AuthController::class, 'profile']);
    Route::post('/auth/profile', [AuthController::class, 'updateProfileWithPhoto']); // Use POST for file uploads

    // Categories
    Route::apiResource('categories', CategoryController::class);

    // Transactions
    Route::apiResource('transactions', TransactionController::class);

    // Budgets
    Route::apiResource('budgets', BudgetController::class);
    Route::get('budgets-with-status', [BudgetController::class, 'getBudgetsWithStatus']);

    // Savings Goals
    Route::apiResource('savings-goals', SavingsGoalController::class);
    Route::get('savings-goals-with-status', [SavingsGoalController::class, 'getSavingsGoalsWithStatus']);
    Route::get('savings-goals-active', [SavingsGoalController::class, 'getActiveSavingsGoals']);

    // Bill Reminders
    Route::apiResource('bill-reminders', BillReminderController::class);
    Route::get('bill-reminders-with-status', [BillReminderController::class, 'getBillRemindersWithStatus']);
    Route::post('bill-reminders/check-and-renew', [BillReminderController::class, 'checkAndRenewDueBills']);

    // Bill Reminder Notifications
    Route::prefix('bill-reminder-notifications')->group(function () {
        Route::get('/', [BillReminderNotificationController::class, 'getBillNotifications']);
        Route::get('/upcoming', [BillReminderNotificationController::class, 'getUpcomingBills']);
        Route::get('/overdue', [BillReminderNotificationController::class, 'getOverdueBills']);
        Route::get('/has-notifications', [BillReminderNotificationController::class, 'hasBillNotifications']);
    });

    // Financial Reports
    Route::prefix('financial-reports')->group(function () {
        Route::get('summary', [FinancialReportController::class, 'getFinancialSummary']);
        Route::get('expense-breakdown', [FinancialReportController::class, 'getExpenseBreakdown']);
        Route::get('budget-vs-actual', [FinancialReportController::class, 'getBudgetVsActual']);
        Route::get('savings-progress', [FinancialReportController::class, 'getSavingsGoalsProgress']);
        Route::get('upcoming-bills', [FinancialReportController::class, 'getUpcomingBills']);
        Route::get('comprehensive', [FinancialReportController::class, 'getComprehensiveReport']);
    });

    // Dashboard Bill Notifications
    Route::get('dashboard/bill-notifications', [DashboardController::class, 'billNotifications']);

    // Financial Analytics
    Route::prefix('financial-analytics')->group(function () {
        Route::get('insights', [FinancialAnalyticsController::class, 'getInsights']);
        Route::get('unread-insights', [FinancialAnalyticsController::class, 'getUnreadInsights']);
        Route::put('insights/{id}/mark-read', [FinancialAnalyticsController::class, 'markInsightAsRead']);
        Route::get('budget-recommendations', [FinancialAnalyticsController::class, 'getBudgetRecommendations']);
        Route::get('recommendations', [FinancialAnalyticsController::class, 'getFinancialRecommendations']);
        Route::get('budget-recommendations-db', [FinancialAnalyticsController::class, 'getBudgetRecommendationsFromDB']);
        Route::put('recommendations/{id}/mark-applied', [FinancialAnalyticsController::class, 'markRecommendationAsApplied']);
        Route::get('predictions', [FinancialAnalyticsController::class, 'getPredictions']);
        Route::get('health-score', [FinancialAnalyticsController::class, 'getFinancialHealthScore']);
        Route::get('comprehensive-analysis', [FinancialAnalyticsController::class, 'getComprehensiveAnalysis']);
    });

    // Financial Notifications
    // Route::prefix('financial-notifications')->group(function () {
    //     Route::get('unread', [FinancialNotificationController::class, 'getUnreadNotifications']);
    //     Route::get('all', [FinancialNotificationController::class, 'getAllNotifications']);
    //     Route::get('type/{type}', [FinancialNotificationController::class, 'getNotificationsByType']);
    //     Route::put('{id}/mark-read', [FinancialNotificationController::class, 'markAsRead']);
    //     Route::post('generate', [FinancialNotificationController::class, 'generateNotifications']);
    // });

    // Reports
    Route::prefix('reports')->group(function () {
        Route::get('daily', [ReportController::class, 'daily']);
        Route::get('monthly', [ReportController::class, 'monthly']);
    });

    // Dashboard
    Route::prefix('dashboard')->group(function () {
        Route::get('summary', [DashboardController::class, 'summary']);
        Route::get('chart', [DashboardController::class, 'chart']);
    });

    // // AI Financial Analysis
    // Route::prefix('ai-analysis')->group(function () {
    //     Route::get('insights', [AiAnalysisController::class, 'getInsights']);
    //     Route::get('spending-pattern', [AiAnalysisController::class, 'getSpendingPattern']);
    //     Route::get('budget-recommendations', [AiAnalysisController::class, 'getBudgetRecommendations']);
    //     Route::get('savings-insights', [AiAnalysisController::class, 'getSavingsInsights']);
    //     Route::post('generate', [AiAnalysisController::class, 'generateAnalysis']);
    //     Route::get('test-connection', [AiAnalysisController::class, 'testConnection']);
    // });

    // Financial Chatbot
    Route::prefix('chatbot')->group(function () {
        Route::post('ask', [FinancialChatbotController::class, 'askQuestion']);
        Route::get('history', [FinancialChatbotController::class, 'getHistory']);
    });

    // Ollama AI Integration
    Route::prefix('ollama')->group(function () {
        Route::post('generate', [OllamaController::class, 'generate']);
        Route::post('financial-insights', [OllamaController::class, 'generateFinancialInsights']);
        Route::post('budget-recommendations', [OllamaController::class, 'generateBudgetRecommendations']);
        Route::post('spending-pattern', [OllamaController::class, 'generateSpendingPatternAnalysis']);
        Route::get('test-connection', [OllamaController::class, 'testConnection']);
    });

    // Health and Self-Test
    Route::get('/health', [HealthController::class, 'health']);
    Route::get('/self-test', [SelfTestController::class, 'selfTest']);
});

// For testing
Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});
