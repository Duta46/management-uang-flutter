<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;

class FinancialHealthScore extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'score',
        'grade',
        'factors',
        'recommendations',
        'confidence_level',
        'calculated_at',
    ];

    protected $casts = [
        'factors' => 'array',
        'recommendations' => 'array',
        'score' => 'integer',
        'confidence_level' => 'decimal:2',
        'calculated_at' => 'datetime',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $hidden = [
        'user_id',
        'created_at',
        'updated_at',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }
}
