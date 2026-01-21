<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\LoginRequest;
use App\Http\Requests\RegisterRequest;
use App\Models\User;
use App\Services\DefaultCategoryService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
        ]);


        // Create default categories for the new user
        $defaultCategoryService = new DefaultCategoryService();
        $defaultCategoryService->createDefaultCategories($user);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ], 201);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid login credentials',
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user,
                'token' => $token,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully',
        ]);
    }

    public function profile(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => $user,
            'message' => 'Profile retrieved successfully',
        ]);
    }

    public function updateProfileWithPhoto(Request $request): JsonResponse
    {
        \Log::info('UpdateProfileWithPhoto called', [
            'user_id' => $request->user()->id,
            'has_file' => $request->hasFile('profile_photo'),
            'fields' => array_keys($request->all())
        ]);

        $request->validate([
            'name' => 'sometimes|string|max:255',
            'email' => 'sometimes|string|email|max:255|unique:users,email,' . $request->user()->id,
            'profile_photo' => 'sometimes|image|mimes:jpeg,png,jpg,gif|max:2048',
        ]);

        $user = $request->user();
        $updates = $request->only(['name', 'email']);

        // Handle profile photo upload
        if ($request->hasFile('profile_photo')) {
            $image = $request->file('profile_photo');

            // Delete old photo if exists
            if ($user->profile_photo) {
                \Storage::disk('public')->delete($user->profile_photo);
            }

            // Save new photo
            $fileName = time() . '_' . $user->id . '.' . $image->getClientOriginalExtension();
            $filePath = $image->storeAs('profile-photos', $fileName, 'public');

            $updates['profile_photo'] = $filePath;
        }

        if (!empty($updates)) {
            $user->update($updates);
        }

        \Log::info('Profile updated with photo', [
            'user_id' => $user->id,
            'profile_photo' => $user->profile_photo
        ]);

        return response()->json([
            'success' => true,
            'data' => [
                'user' => $user
            ],
            'message' => 'Profile updated successfully',
        ]);
    }
}