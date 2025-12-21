<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Http;

class SelfTestController extends Controller
{
    public function selfTest(): JsonResponse
    {
        $baseUrl = request()->getSchemeAndHttpHost() . '/api';
        
        // Check each API endpoint
        $authCheck = $this->checkEndpoint("$baseUrl/auth/test");
        $categoryCheck = $this->checkEndpoint("$baseUrl/categories");
        $transactionCheck = $this->checkEndpoint("$baseUrl/transactions");
        $reportCheck = $this->checkEndpoint("$baseUrl/reports/monthly");
        $dashboardCheck = $this->checkEndpoint("$baseUrl/dashboard/summary");
        
        return response()->json([
            'status' => 'OK',
            'api_check' => [
                'auth' => $authCheck,
                'category' => $categoryCheck,
                'transaction' => $transactionCheck,
                'report' => $reportCheck,
                'dashboard' => $dashboardCheck
            ]
        ]);
    }
    
    private function checkEndpoint(string $url): bool
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . request()->bearerToken(),
                'Accept' => 'application/json'
            ])->get($url);
            
            return $response->successful();
        } catch (\Exception $e) {
            return false;
        }
    }
}