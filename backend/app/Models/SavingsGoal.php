<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class SavingsGoal extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'name',
        'description',
        'target_amount',
        'current_amount',
        'target_date',
        'status',
    ];

    protected $casts = [
        'target_amount' => 'decimal:2',
        'current_amount' => 'decimal:2',
        'target_date' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $hidden = [
        'user_id',
        'created_at',
        'updated_at',
    ];

    protected $appends = [
        'progress_percentage',
        'amount_needed',
        'days_remaining',
        'status_text',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    // Accessor untuk menghitung persentase progress
    public function getProgressPercentageAttribute(): float
    {
        if ($this->target_amount == 0) {
            return 0.0;
        }

        $percentage = ($this->current_amount / $this->target_amount) * 100;
        return round($percentage, 2);
    }

    // Accessor untuk menghitung jumlah yang masih dibutuhkan
    public function getAmountNeededAttribute(): float
    {
        $needed = $this->target_amount - $this->current_amount;
        return $needed > 0 ? $needed : 0.0;
    }

    // Accessor untuk menghitung hari tersisa hingga target date
    public function getDaysRemainingAttribute(): int
    {
        $targetDate = \Carbon\Carbon::parse($this->target_date);
        $today = \Carbon\Carbon::today();

        if ($targetDate->lessThan($today)) {
            // Jika tanggal target sudah lewat, kembalikan 0
            return 0;
        }

        return $targetDate->diffInDays($today);
    }

    // Accessor untuk status teks
    public function getStatusTextAttribute(): string
    {
        if ($this->current_amount >= $this->target_amount) {
            return 'achieved';
        }

        $today = \Carbon\Carbon::today();
        $targetDate = \Carbon\Carbon::parse($this->target_date);

        if ($targetDate->lessThan($today)) {
            return 'overdue';
        }

        return 'active';
    }
}
