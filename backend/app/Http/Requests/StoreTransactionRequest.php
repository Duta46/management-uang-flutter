<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => 'required_without:bill_reminder_id,savings_goal_id|exists:categories,id',
            'bill_reminder_id' => 'required_without:category_id,savings_goal_id|exists:bill_reminders,id',
            'savings_goal_id' => 'required_without:category_id,bill_reminder_id|exists:savings_goals,id',
            'amount' => 'required|numeric|min:0.01',
            'type' => 'required|in:income,expense',
            'description' => 'nullable|string|max:255',
            'date' => 'required|date',
        ];
    }

    public function messages(): array
    {
        return [
            'category_id.required_without' => 'Category is required when not selecting a bill reminder or savings goal',
            'bill_reminder_id.required_without' => 'Bill reminder is required when not selecting a category or savings goal',
            'savings_goal_id.required_without' => 'Savings goal is required when not selecting a category or bill reminder',
            'category_id.exists' => 'Selected category does not exist',
            'bill_reminder_id.exists' => 'Selected bill reminder does not exist',
            'savings_goal_id.exists' => 'Selected savings goal does not exist',
            'amount.required' => 'Amount is required',
            'type.required' => 'Type is required',
            'date.required' => 'Date is required',
        ];
    }
}