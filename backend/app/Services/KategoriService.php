<?php
/**
 * Copyright (c) 2026 Duta Alif Gunawan
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

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