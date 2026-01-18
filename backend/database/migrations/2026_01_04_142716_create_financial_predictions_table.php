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
        Schema::create('financial_predictions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('type'); // savings_projection, expense_projection, budget_projection
            $table->json('data'); // Prediction data
            $table->string('period'); // monthly, quarterly, yearly
            $table->date('prediction_date'); // Date of prediction
            $table->decimal('confidence_level', 5, 2)->default(80.00); // Confidence level of prediction in percentage
            $table->boolean('is_active')->default(true); // Whether the prediction is still relevant
            $table->timestamp('generated_at')->useCurrent(); // When the prediction was generated
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('financial_predictions');
    }
};
