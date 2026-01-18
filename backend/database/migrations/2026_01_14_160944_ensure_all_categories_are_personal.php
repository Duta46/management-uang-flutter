<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Set semua kategori yang tersisa menjadi non-global (is_global = 0)
        DB::table('categories')
          ->update(['is_global' => 0]);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Tidak ada rollback karena kita hanya menormalkan data
    }
};
