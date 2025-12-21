<?php

namespace App\Repositories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

class CategoryRepository implements CategoryRepositoryInterface
{
    public function getAll(int $userId): Collection
    {
        return Category::where('user_id', $userId)->get();
    }

    public function getById(int $id, int $userId): ?Category
    {
        return Category::where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    public function create(array $data): Category
    {
        return Category::create($data);
    }

    public function update(int $id, int $userId, array $data): ?Category
    {
        $category = $this->getById($id, $userId);
        
        if ($category) {
            $category->update($data);
            return $category;
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $category = $this->getById($id, $userId);
        
        if ($category) {
            return $category->delete();
        }

        return false;
    }
}