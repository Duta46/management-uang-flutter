<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreCategoryRequest;
use App\Http\Requests\UpdateCategoryRequest;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class CategoryController extends BaseController
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        
        // Check if user has admin role
        if ($user->hasRole('admin')) {
            $categories = Category::with('user')->paginate(10);
        } else {
            $categories = $user->categories()->paginate(10);
        }

        return $this->sendResponse($categories, 'Categories retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreCategoryRequest $request)
    {
        $user = Auth::user();
        $input = $request->validated();
        $input['user_id'] = $user->id;

        $category = Category::create($input);

        return $this->sendResponse($category, 'Category created successfully.', 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Category $category)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the category
        if (!$user->hasRole('admin') && $category->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        return $this->sendResponse($category, 'Category retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateCategoryRequest $request, Category $category)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the category
        if (!$user->hasRole('admin') && $category->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $category->update($request->validated());

        return $this->sendResponse($category, 'Category updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Category $category)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the category
        if (!$user->hasRole('admin') && $category->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $category->delete();

        return $this->sendResponse([], 'Category deleted successfully.');
    }
}
