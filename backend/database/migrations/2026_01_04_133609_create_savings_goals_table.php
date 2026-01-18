<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('savings_goals', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name'); // Nama target tabungan
            $table->text('description')->nullable(); // Deskripsi target
            $table->decimal('target_amount', 15, 2); // Jumlah target
            $table->decimal('current_amount', 15, 2)->default(0); // Jumlah saat ini
            $table->date('target_date'); // Tanggal target
            $table->string('status')->default('active'); // Status: active, achieved, cancelled
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('savings_goals');
    }
};
