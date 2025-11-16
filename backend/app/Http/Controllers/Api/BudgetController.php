<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBudgetRequest;
use App\Http\Requests\UpdateBudgetRequest;
use App\Models\Budget;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class BudgetController extends BaseController
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        
        // Check if user has admin role
        if ($user->hasRole('admin')) {
            $budgets = Budget::with(['user', 'category'])->paginate(10);
        } else {
            $budgets = $user->budgets()->with('category')->paginate(10);
        }

        return $this->sendResponse($budgets, 'Budgets retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreBudgetRequest $request)
    {
        $user = Auth::user();
        $input = $request->validated();
        $input['user_id'] = $user->id;

        $budget = Budget::create($input);

        return $this->sendResponse($budget, 'Budget created successfully.', 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Budget $budget)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the budget
        if (!$user->hasRole('admin') && $budget->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        return $this->sendResponse($budget->load('category'), 'Budget retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateBudgetRequest $request, Budget $budget)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the budget
        if (!$user->hasRole('admin') && $budget->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $budget->update($request->validated());

        return $this->sendResponse($budget->load('category'), 'Budget updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Budget $budget)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the budget
        if (!$user->hasRole('admin') && $budget->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $budget->delete();

        return $this->sendResponse([], 'Budget deleted successfully.');
    }
}
