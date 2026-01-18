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
        Schema::create('financial_health_scores', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->integer('score'); // Score from 0-100
            $table->string('grade'); // Sangat Baik, Baik, Cukup, Kurang, Buruk
            $table->json('factors'); // Factors that influenced the score
            $table->json('recommendations'); // Recommendations for improvement
            $table->decimal('confidence_level', 5, 2)->default(90.00); // Confidence level of the score
            $table->timestamp('calculated_at')->useCurrent(); // When the score was calculated
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('financial_health_scores');
    }
};
