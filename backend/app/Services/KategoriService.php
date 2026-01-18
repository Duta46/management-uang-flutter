<?php

namespace App\Services;

use App\Repositories\CategoryRepositoryInterface;
use App\Models\Category;

class KategoriService implements KategoriServiceInterface
{
    private CategoryRepositoryInterface $kategoriRepository;

    public function __construct(CategoryRepositoryInterface $kategoriRepository)
    {
        $this->kategoriRepository = $kategoriRepository;
    }

    public function getAllCategories(int $userId)
    {
        return $this->kategoriRepository->getAllForUser($userId);
    }

    public function getCategory(int $id, int $userId): ?Category
    {
        return $this->kategoriRepository->getById($id, $userId);
    }

    public function createCategory(array $data): Category
    {
        return $this->kategoriRepository->create($data);
    }

    public function updateCategory(int $id, int $userId, array $data): ?Category
    {
        return $this->kategoriRepository->update($id, $userId, $data);
    }

    public function deleteCategory(int $id, int $userId): bool
    {
        return $this->kategoriRepository->delete($id, $userId);
    }
}