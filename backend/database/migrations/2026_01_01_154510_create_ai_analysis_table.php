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
        Schema::create('ai_analysis', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('analysis_type'); // e.g., 'spending_pattern', 'budget_recommendation', 'savings_insight'
            $table->json('analysis_data'); // Store the analysis results as JSON
            $table->text('insight')->nullable(); // Human-readable insight
            $table->text('recommendation')->nullable(); // Recommendation based on analysis
            $table->date('analysis_date'); // Date of analysis
            $table->timestamps();

            // Index for performance
            $table->index(['user_id', 'analysis_type', 'analysis_date']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('ai_analysis');
    }
};
