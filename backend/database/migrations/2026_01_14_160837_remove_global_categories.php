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
        // Hapus semua kategori global (is_global = 1)
        DB::table('categories')
          ->where('is_global', 1)
          ->delete();
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Karena kita menghapus data, tidak ada cara untuk mengembalikannya
        // Kita bisa menambahkan kategori global default jika perlu
        // Tapi untuk saat ini, biarkan kosong karena ini hanya migrasi sekali pakai
    }
};
