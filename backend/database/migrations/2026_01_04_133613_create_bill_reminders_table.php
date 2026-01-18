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
        Schema::create('bill_reminders', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('name'); // Nama tagihan
            $table->text('description')->nullable(); // Deskripsi tagihan
            $table->decimal('amount', 15, 2); // Jumlah tagihan
            $table->date('due_date'); // Tanggal jatuh tempo
            $table->string('frequency'); // Frekuensi: monthly, weekly, yearly, one_time
            $table->boolean('is_paid')->default(false); // Status pembayaran
            $table->boolean('is_active')->default(true); // Status aktif
            $table->date('next_due_date'); // Tanggal jatuh tempo berikutnya
            $table->timestamps();
            $table->softDeletes();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('bill_reminders');
    }
};
