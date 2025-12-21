<?php

namespace App\Services;

use App\Repositories\CategoryRepositoryInterface;
use App\Models\Category;

class CategoryService implements CategoryServiceInterface
{
    private CategoryRepositoryInterface $categoryRepository;

    public function __construct(CategoryRepositoryInterface $categoryRepository)
    {
        $this->categoryRepository = $categoryRepository;
    }

    public function getAllCategories(int $userId)
    {
        return $this->categoryRepository->getAll($userId);
    }

    public function getCategory(int $id, int $userId): ?Category
    {
        return $this->categoryRepository->getById($id, $userId);
    }

    public function createCategory(array $data): Category
    {
        return $this->categoryRepository->create($data);
    }

    public function updateCategory(int $id, int $userId, array $data): ?Category
    {
        return $this->categoryRepository->update($id, $userId, $data);
    }

    public function deleteCategory(int $id, int $userId): bool
    {
        return $this->categoryRepository->delete($id, $userId);
    }
}