<?php

namespace App\Repositories;

use App\Models\AiAnalysis;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

interface AiAnalysisRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator;
    public function getById(int $id, int $userId): ?AiAnalysis;
    public function create(array $data): AiAnalysis;
    public function update(int $id, int $userId, array $data): ?AiAnalysis;
    public function delete(int $id, int $userId): bool;
    public function getByUserId(int $userId): Collection;
}