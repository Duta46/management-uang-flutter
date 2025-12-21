<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Category;
use App\Models\User;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $user = User::first(); // Get the first user created

        if ($user) {
            // Sample categories
            Category::create([
                'user_id' => $user->id,
                'name' => 'Salary',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Investment',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Bonus',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Food',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Transportation',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Shopping',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Entertainment',
            ]);

            Category::create([
                'user_id' => $user->id,
                'name' => 'Utilities',
            ]);
        }
    }
}