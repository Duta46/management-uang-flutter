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
        if (Schema::hasColumn('categories', 'created_by_admin_id')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->dropColumn('created_by_admin_id');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (!Schema::hasColumn('categories', 'created_by_admin_id')) {
            Schema::table('categories', function (Blueprint $table) {
                $table->unsignedBigInteger('created_by_admin_id')->nullable()->after('is_global');
            });
        }
    }
};
