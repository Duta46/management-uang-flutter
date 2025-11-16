<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreSavingRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'goal_name' => 'required|string|max:100',
            'target_amount' => 'required|numeric|min:0.01',
            'current_amount' => 'nullable|numeric|min:0',
            'deadline' => 'required|date|after:today',
        ];
    }

    /**
     * Get custom messages for validation errors.
     *
     * @return array
     */
    public function messages(): array
    {
        return [
            'goal_name.required' => 'Goal name is required.',
            'goal_name.max' => 'Goal name may not be greater than 100 characters.',
            'target_amount.required' => 'Target amount is required.',
            'target_amount.numeric' => 'Target amount must be a number.',
            'target_amount.min' => 'Target amount must be at least 0.01.',
            'current_amount.numeric' => 'Current amount must be a number.',
            'current_amount.min' => 'Current amount must be at least 0.',
            'deadline.required' => 'Deadline is required.',
            'deadline.date' => 'Deadline must be a valid date.',
            'deadline.after' => 'Deadline must be a future date.',
        ];
    }
}
