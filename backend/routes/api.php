<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\TransactionController;
use App\Http\Controllers\Api\BudgetController;
use App\Http\Controllers\Api\SavingController;

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/auth/google', [AuthController::class, 'googleLogin']);

// Protected routes
Route::middleware(['auth:sanctum'])->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    
    // Category routes
    Route::apiResource('categories', CategoryController::class);
    
    // Transaction routes
    Route::apiResource('transactions', TransactionController::class);

    // Financial summary routes
    Route::get('/financial-summary', [TransactionController::class, 'getFinancialSummary']);
    Route::get('/monthly-financial-data', [TransactionController::class, 'getMonthlyFinancialData']);
    
    // Budget routes
    Route::apiResource('budgets', BudgetController::class);
    
    // Saving routes
    Route::apiResource('savings', SavingController::class);
    
    // Admin-specific routes
    Route::middleware(['role:admin'])->group(function () {
        // Admin can access all resources
        Route::get('/admin/transactions', [TransactionController::class, 'index']);
        Route::get('/admin/categories', [CategoryController::class, 'index']);
        Route::get('/admin/budgets', [BudgetController::class, 'index']);
        Route::get('/admin/savings', [SavingController::class, 'index']);
        Route::get('/admin/users', function () {
            return new \App\Http\Resources\UserCollection(\App\Models\User::with('roles')->paginate(10));
        });
    });
});

// For testing authentication
Route::middleware(['auth:sanctum'])->get('/user', function (Request $request) {
    return $request->user();
});
