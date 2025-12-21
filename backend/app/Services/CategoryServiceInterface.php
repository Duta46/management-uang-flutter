<?php

namespace App\Services;

use App\Repositories\CategoryRepositoryInterface;
use App\Models\Category;

interface CategoryServiceInterface
{
    public function getAllCategories(int $userId);
    public function getCategory(int $id, int $userId): ?Category;
    public function createCategory(array $data): Category;
    public function updateCategory(int $id, int $userId, array $data): ?Category;
    public function deleteCategory(int $id, int $userId): bool;
}
