<?php
// File: test_api.php
// Digunakan untuk testing endpoint API

require_once 'vendor/autoload.php';

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

// Bootstrap Laravel application
$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

// Ambil user ID pertama dari database untuk testing
$user = DB::table('users')->first();
if (!$user) {
    echo "Tidak ada user dalam database. Silakan buat user terlebih dahulu.\n";
    exit(1);
}

// Buat request untuk testing
$input = [
    'question' => 'halo'
];

// Kita tidak bisa mengakses token dengan cara ini di file test sederhana
// Jadi kita akan coba dengan user ID yang valid
$headers = [
    'CONTENT_TYPE' => 'application/json',
    'HTTP_ACCEPT' => 'application/json',
];

// Simulasikan request
$request = Request::create('/api/chatbot/ask', 'POST', $input, [], [], $headers);

try {
    // Tangani request
    $response = $app->handle($request);

    echo "Status Code: " . $response->getStatusCode() . "\n";
    echo "Response Body: " . $response->getContent() . "\n";

    if ($response->getStatusCode() >= 400) {
        echo "Error occurred!\n";
    }
} catch (Exception $e) {
    echo "Exception caught: " . $e->getMessage() . "\n";
    echo "File: " . $e->getFile() . "\n";
    echo "Line: " . $e->getLine() . "\n";
    echo "Trace: " . $e->getTraceAsString() . "\n";
}