<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\SoftDeletes;

class AiAnalysis extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id',
        'analysis_type',
        'analysis_data',
        'insight',
        'recommendation',
        'analysis_date',
    ];

    protected $casts = [
        'analysis_data' => 'array',
        'analysis_date' => 'date',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

    protected $hidden = [
        'user_id',
        'created_at',
        'updated_at',
        'deleted_at',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
