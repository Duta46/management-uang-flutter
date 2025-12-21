<?php

namespace App\Repositories;

use App\Models\Category;
use Illuminate\Database\Eloquent\Collection;

interface CategoryRepositoryInterface
{
    public function getAll(int $userId): Collection;
    public function getById(int $id, int $userId): ?Category;
    public function create(array $data): Category;
    public function update(int $id, int $userId, array $data): ?Category;
    public function delete(int $id, int $userId): bool;
}