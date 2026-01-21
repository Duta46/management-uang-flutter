<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Hapus tabel budgets
        Schema::dropIfExists('budgets');
        
        // Hapus juga entri yang terkait di tabel lain jika ada
        // Misalnya di tabel notifications, recommendations, dll yang mungkin menyimpan referensi ke budget
        DB::statement("DELETE FROM financial_notifications WHERE type = 'budget_alert'");
        DB::statement("DELETE FROM financial_recommendations WHERE type = 'budget_recommendation'");
        DB::statement("DELETE FROM ai_analysis WHERE analysis_type = 'budget_recommendation'");
        DB::statement("DELETE FROM financial_predictions WHERE type = 'budget_projection'");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Karena kita menghapus tabel, kita tidak bisa mengembalikannya ke bentuk semula
        // tanpa membuat ulang struktur tabel, jadi kita biarkan kosong atau beri pesan
        echo "Tidak dapat mengembalikan tabel budgets karena telah dihapus permanen.\n";
    }
};