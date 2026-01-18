<?php

namespace App\Http\Middleware;

use Illuminate\Foundation\Http\Middleware\ValidatePathEncoding as BaseValidatePathEncoding;
use Illuminate\Http\Request;

class ValidatePathEncoding extends BaseValidatePathEncoding
{
    /**
     * Get the path that should not be validated for encoding.
     *
     * @return array
     */
    protected function except()
    {
        return [
            'api/*',
            'api/v1/*',
            'savings-goals/*',
            'savings-goals',
            'transactions/*',
            'transactions',
        ];
    }

    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle($request, \Closure $next)
    {
        // Logging untuk melihat apakah middleware ini menyebabkan masalah
        \Log::info('ValidatePathEncoding middleware called', [
            'path' => $request->path(),
            'method' => $request->method(),
            'ip' => $request->ip()
        ]);

        return parent::handle($request, $next);
    }
}