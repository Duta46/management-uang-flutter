<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->enum('type', ['income', 'expense'])->after('name')->nullable();
        });
        
        // Set default types for common category names
        DB::table('categories')->where(DB::raw('LOWER(name)'), 'like', '%salary%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%income%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%bonus%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%investment%')
            ->update(['type' => 'income']);
            
        DB::table('categories')->where(DB::raw('LOWER(name)'), 'like', '%food%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%grocer%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%dining%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%transport%')
            ->orWhere(DB::raw('LOWER(name)'), 'like', '%utilit%')
            ->update(['type' => 'expense']);
    }

    public function down(): void
    {
        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn('type');
        });
    }
};