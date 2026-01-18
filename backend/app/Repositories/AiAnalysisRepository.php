<?php

namespace App\Repositories;

use App\Models\AiAnalysis;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Pagination\LengthAwarePaginator;

class AiAnalysisRepository implements AiAnalysisRepositoryInterface
{
    public function getAll(int $userId, array $filters = []): LengthAwarePaginator
    {
        $query = AiAnalysis::where('user_id', $userId);

        if (isset($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        if (isset($filters['created_at'])) {
            $query->whereDate('created_at', $filters['created_at']);
        }

        return $query->orderBy('created_at', 'desc')->paginate($filters['per_page'] ?? 15);
    }

    public function getById(int $id, int $userId): ?AiAnalysis
    {
        return AiAnalysis::where('id', $id)
            ->where('user_id', $userId)
            ->first();
    }

    public function create(array $data): AiAnalysis
    {
        return AiAnalysis::create($data);
    }

    public function update(int $id, int $userId, array $data): ?AiAnalysis
    {
        $aiAnalysis = $this->getById($id, $userId);

        if ($aiAnalysis) {
            $aiAnalysis->update($data);
            return $aiAnalysis;
        }

        return null;
    }

    public function delete(int $id, int $userId): bool
    {
        $aiAnalysis = $this->getById($id, $userId);

        if ($aiAnalysis) {
            return $aiAnalysis->delete();
        }

        return false;
    }

    public function getByUserId(int $userId): Collection
    {
        return AiAnalysis::where('user_id', $userId)->get();
    }
}