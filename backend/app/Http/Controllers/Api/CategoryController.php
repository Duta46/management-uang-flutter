<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CategoryServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    private CategoryServiceInterface $categoryService;

    public function __construct(CategoryServiceInterface $categoryService)
    {
        $this->categoryService = $categoryService;
    }

    public function index(): JsonResponse
    {
        $userId = auth()->id();
        $categories = $this->categoryService->getAllCategories($userId);

        return response()->json([
            'success' => true,
            'data' => $categories,
            'message' => 'Categories retrieved successfully',
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $userId = auth()->id();
        
        $request->validate([
            'name' => 'required|string|max:255',
        ]);

        $data = $request->all();
        $data['user_id'] = $userId;
        
        $category = $this->categoryService->createCategory($data);

        return response()->json([
            'success' => true,
            'data' => $category,
            'message' => 'Category created successfully',
        ], 201);
    }

    public function show(int $id): JsonResponse
    {
        $userId = auth()->id();
        $category = $this->categoryService->getCategory($id, $userId);

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $category,
            'message' => 'Category retrieved successfully',
        ]);
    }

    public function update(Request $request, int $id): JsonResponse
    {
        $userId = auth()->id();
        
        $request->validate([
            'name' => 'sometimes|string|max:255',
        ]);

        $category = $this->categoryService->updateCategory($id, $userId, $request->all());

        if (!$category) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $category,
            'message' => 'Category updated successfully',
        ]);
    }

    public function destroy(int $id): JsonResponse
    {
        $userId = auth()->id();
        $deleted = $this->categoryService->deleteCategory($id, $userId);

        if (!$deleted) {
            return response()->json([
                'success' => false,
                'message' => 'Category not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => null,
            'message' => 'Category deleted successfully',
        ]);
    }
}