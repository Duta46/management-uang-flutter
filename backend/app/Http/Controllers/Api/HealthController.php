<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class HealthController extends Controller
{
    public function health(): JsonResponse
    {
        return response()->json([
            'status' => 'OK',
            'timestamp' => now()->toISOString(),
            'version' => '1.0.0',
            'database' => \DB::connection()->getPdo() ? 'connected' : 'disconnected',
        ]);
    }
}