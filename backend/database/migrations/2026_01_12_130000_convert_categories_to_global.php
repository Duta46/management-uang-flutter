<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add is_global column to identify global categories
        Schema::table('categories', function (Blueprint $table) {
            $table->boolean('is_global')->default(false)->after('type');
        });
        
        // Temporarily remove foreign key constraint to allow NULL user_id for global categories
        Schema::table('categories', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
        });
        
        Schema::table('categories', function (Blueprint $table) {
            $table->unsignedBigInteger('user_id')->nullable()->change();
        });
        
        // Add foreign key back with ON DELETE SET NULL
        Schema::table('categories', function (Blueprint $table) {
            $table->foreign('user_id')->references('id')->on('users')->onDelete('set null');
        });
        
        // Create a pivot table to link users with global categories
        Schema::create('user_global_categories', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id');
            $table->unsignedBigInteger('category_id');
            $table->timestamps();
            
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
            $table->foreign('category_id')->references('id')->on('categories')->onDelete('cascade');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_global_categories');
        
        Schema::table('categories', function (Blueprint $table) {
            $table->dropForeign(['user_id']);
            $table->unsignedBigInteger('user_id')->nullable(false)->change();
            $table->foreign('user_id')->references('id')->on('users')->onDelete('cascade');
        });
        
        Schema::table('categories', function (Blueprint $table) {
            $table->dropColumn(['is_global']);
        });
    }
};