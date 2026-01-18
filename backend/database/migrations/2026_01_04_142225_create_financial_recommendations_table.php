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
        Schema::create('financial_recommendations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('type'); // budget_recommendation, savings_recommendation, expense_reduction, investment_advice
            $table->string('title');
            $table->text('description');
            $table->json('data')->nullable(); // Additional data for the recommendation
            $table->string('priority')->default('low'); // low, medium, high, critical
            $table->boolean('is_applied')->default(false); // Whether the user has applied the recommendation
            $table->timestamp('applied_at')->nullable(); // When the recommendation was applied
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('financial_recommendations');
    }
};
