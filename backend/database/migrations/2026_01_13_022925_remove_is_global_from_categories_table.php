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
        if (Schema::hasColumn('categories', 'is_global')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->dropColumn('is_global');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (!Schema::hasColumn('categories', 'is_global')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->boolean('is_global')->default(false)->after('name');
            });
        }
    }
};
