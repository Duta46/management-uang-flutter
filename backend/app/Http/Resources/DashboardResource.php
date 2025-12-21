<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class DashboardResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'month' => $this->month,
            'year' => $this->year,
            'income' => $this->income,
            'expense' => $this->expense,
            'balance' => $this->balance,
        ];
    }
}