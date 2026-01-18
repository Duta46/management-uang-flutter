<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateTransactionRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'category_id' => 'sometimes|required_without:bill_reminder_id,savings_goal_id|exists:categories,id',
            'bill_reminder_id' => 'sometimes|required_without:category_id,savings_goal_id|exists:bill_reminders,id',
            'savings_goal_id' => 'sometimes|required_without:category_id,bill_reminder_id|exists:savings_goals,id',
            'amount' => 'sometimes|numeric|min:0.01',
            'type' => 'sometimes|in:income,expense',
            'description' => 'nullable|string|max:255',
            'date' => 'sometimes|date',
        ];
    }
}