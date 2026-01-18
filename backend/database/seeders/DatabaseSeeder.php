<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use App\Models\User;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create users first
        $johnUser = User::factory()->create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => Hash::make('password'),
            'email_verified_at' => now(), // Pastikan email terverifikasi
        ]);

        $janeUser = \App\Models\User::create([
            'name' => 'Jane Doe',
            'email' => 'jane@example.com',
            'password' => Hash::make('password123'),
            'email_verified_at' => now(),
        ]);

        // Tidak ada role lagi, semua user dianggap sama

        // Call other seeders
        $this->call([
            CategorySeeder::class
        ]);
    }
}
