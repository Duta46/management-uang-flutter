<?php

namespace App\Services;

use App\Models\Category;
use App\Models\User;

class DefaultCategoryService
{
    public function createDefaultCategories(User $user): void
    {
        $defaultCategories = [
            ['name' => 'Salary'],
            ['name' => 'Investment'],
            ['name' => 'Bonus'],
            ['name' => 'Food'],
            ['name' => 'Transportation'],
            ['name' => 'Shopping'],
            ['name' => 'Entertainment'],
            ['name' => 'Utilities'],
        ];

        foreach ($defaultCategories as $categoryData) {
            Category::create([
                'user_id' => $user->id,
                'name' => $categoryData['name'],
                'type' => $categoryData['type'],
            ]);
        }
    }
}