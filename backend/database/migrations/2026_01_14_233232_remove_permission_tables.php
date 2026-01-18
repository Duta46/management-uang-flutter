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
        // Hapus tabel-tabel permission jika ada
        $tableNames = config('permission.table_names');

        if (isset($tableNames)) {
            foreach (['role_has_permissions', 'model_has_roles', 'model_has_permissions', 'roles', 'permissions'] as $tableName) {
                if (Schema::hasTable($tableNames[$tableName] ?? $tableName)) {
                    Schema::dropIfExists($tableNames[$tableName] ?? $tableName);
                }
            }
        } else {
            // Jika konfigurasi tidak ditemukan, hapus tabel dengan nama default
            Schema::dropIfExists('role_has_permissions');
            Schema::dropIfExists('model_has_roles');
            Schema::dropIfExists('model_has_permissions');
            Schema::dropIfExists('roles');
            Schema::dropIfExists('permissions');
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Karena ini adalah penghapusan tabel, kita tidak bisa mengembalikannya
        // Tapi kita bisa menambahkan kembali struktur dasar jika diperlukan
    }
};
