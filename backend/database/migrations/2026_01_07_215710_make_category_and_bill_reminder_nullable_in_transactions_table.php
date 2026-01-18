<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            // Ubah category_id menjadi nullable
            $table->unsignedBigInteger('category_id')->nullable()->change();
            // Ubah bill_reminder_id menjadi nullable
            $table->unsignedBigInteger('bill_reminder_id')->nullable()->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('transactions', function (Blueprint $table) {
            // Kembalikan category_id ke non-nullable
            $table->unsignedBigInteger('category_id')->nullable(false)->change();
            // Kembalikan bill_reminder_id ke non-nullable
            $table->unsignedBigInteger('bill_reminder_id')->nullable(false)->change();
        });
    }
};
