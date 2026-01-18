<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\KategoriService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    private KategoriService $kategoriService;

    public function __construct(KategoriService $kategoriService)
    {
        $this->kategoriService = $kategoriService;
    }

    public function index(): JsonResponse
    {
        $userId = auth()->id();

        $categories = $this->kategoriService->getAllCategories($userId);

        return response()->json([
            'success' => true,
            'data' => $categories,
            'message' => 'Kategori berhasil diambil',
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $userId = auth()->id();

        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $data = $request->all();

        // Always create personal category (no global categories anymore)
        $data['user_id'] = $userId;
        $data['is_global'] = false;

        $category = $this->kategoriService->createCategory($data);

        return response()->json([
            'success' => true,
            'data' => $category,
            'message' => 'Kategori berhasil dibuat',
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $userId = auth()->id();
        $category = $this->kategoriService->getCategory($id, $userId);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $category,
            'message' => 'Kategori berhasil diambil',
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $userId = auth()->id();

        $request->validate([
            'name' => 'sometimes|string|max:255',
        ]);

        // Get the category to check ownership
        $category = $this->kategoriService->getCategory($id, $userId);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan',
            ], 404);
        }

        // User can only update their own categories
        if ($category['user_id'] != $userId) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki izin untuk mengubah kategori ini',
            ], 403);
        }

        $category = $this->kategoriService->updateCategory($id, $userId, $request->all());

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $category,
            'message' => 'Kategori berhasil diperbarui',
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $userId = auth()->id();

        // Get the category to check ownership
        $category = $this->kategoriService->getCategory($id, $userId);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan',
            ], 404);
        }

        // User can only delete their own categories
        if ($category['user_id'] != $userId) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki izin untuk menghapus kategori ini',
            ], 403);
        }

        $deleted = $this->kategoriService->deleteCategory($id, $userId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Kategori tidak ditemukan',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Kategori berhasil dihapus',
        ]);
    }
}