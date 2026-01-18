<?php

namespace App\Providers;

use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Foundation\Http\Middleware\ValidatePathEncoding;
use Illuminate\Support\ServiceProvider;
use App\Http\Middleware\ValidatePathEncoding as CustomValidatePathEncoding;
use App\Services\KategoriServiceInterface;
use App\Services\KategoriService;
use App\Repositories\CategoryRepositoryInterface;
use App\Repositories\CategoryRepository;
use App\Services\TransactionServiceInterface;
use App\Services\TransactionService;
use App\Repositories\TransactionRepositoryInterface;
use App\Repositories\TransactionRepository;
use App\Services\AiAnalysisServiceInterface;
use App\Services\AiAnalysisService;
use App\Services\FinancialChatbotServiceInterface;
use App\Services\FinancialChatbotService;
use App\Services\OllamaServiceInterface;
use App\Services\OllamaService;
use App\Services\SavingsGoalService;
use App\Services\BillReminderService;
use App\Services\BudgetService;
use App\Repositories\SavingsGoalRepositoryInterface;
use App\Repositories\SavingsGoalRepository;
use App\Repositories\BillReminderRepositoryInterface;
use App\Repositories\BillReminderRepository;
use App\Repositories\BudgetRepositoryInterface;
use App\Repositories\BudgetRepository;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Binding interface ke implementasi
        $this->app->bind(KategoriServiceInterface::class, KategoriService::class);
        $this->app->bind(CategoryRepositoryInterface::class, CategoryRepository::class);
        $this->app->bind(TransactionServiceInterface::class, TransactionService::class);
        $this->app->bind(TransactionRepositoryInterface::class, TransactionRepository::class);
        $this->app->bind(AiAnalysisServiceInterface::class, AiAnalysisService::class);
        $this->app->bind(FinancialChatbotServiceInterface::class, FinancialChatbotService::class);
        $this->app->bind(OllamaServiceInterface::class, OllamaService::class);
        $this->app->bind(SavingsGoalRepositoryInterface::class, SavingsGoalRepository::class);
        $this->app->bind(SavingsGoalService::class, SavingsGoalService::class);
        $this->app->bind(BillReminderRepositoryInterface::class, BillReminderRepository::class);
        $this->app->bind(BillReminderService::class, BillReminderService::class);
        $this->app->bind(BudgetRepositoryInterface::class, BudgetRepository::class);
        $this->app->bind(BudgetService::class, BudgetService::class);
        // $this->app->singleton(GeminiService::class, function ($app) {
        //     return new GeminiService();
        // });

        // Ganti middleware ValidatePathEncoding dengan versi kustom
        $this->app->bind(ValidatePathEncoding::class, CustomValidatePathEncoding::class);
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        ResetPassword::createUrlUsing(function (object $notifiable, string $token) {
            return config('app.frontend_url')."/password-reset/$token?email={$notifiable->getEmailForPasswordReset()}";
        });
    }
}
