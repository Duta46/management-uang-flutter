<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SavingResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->user_id,
            'goal_name' => $this->goal_name,
            'target_amount' => number_format($this->target_amount, 2, '.', ''),
            'current_amount' => number_format($this->current_amount, 2, '.', ''),
            'deadline' => $this->deadline->format('Y-m-d'),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'progress_percentage' => $this->target_amount > 0 ? round(($this->current_amount / $this->target_amount) * 100, 2) : 0,
        ];
    }
}
