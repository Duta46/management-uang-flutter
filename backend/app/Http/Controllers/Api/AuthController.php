<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Laravel\Socialite\Facades\Socialite;
use Illuminate\Support\Facades\Log;

class AuthController extends BaseController
{
    /**
     * Register a new user.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'email' => 'required|string|email|max:100|unique:users',
            'password' => 'required|string|min:8|confirmed',
        ]);

        if ($validator->fails()) {
            return $this->sendError('Validation Error.', $validator->errors(), 422);
        }

        $input = $request->all();
        $input['password'] = Hash::make($input['password']);
        
        $user = User::create($input);
        $user->assignRole('user'); // Assign default user role
        
        $success['token'] = $user->createToken('Personal Access Token')->plainTextToken;
        $success['name'] = $user->name;

        return $this->sendResponse($success, 'User register successfully.', 201);
    }

    /**
     * Login user.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required',
        ]);

        if ($validator->fails()) {
            return $this->sendError('Validation Error.', $validator->errors(), 422);
        }

        if (Auth::attempt(['email' => $request->email, 'password' => $request->password])) {
            $user = Auth::user();
            $success['token'] = $user->createToken('Personal Access Token')->plainTextToken;
            $success['name'] = $user->name;
            $success['email'] = $user->email;

            return $this->sendResponse($success, 'User login successfully.');
        } else {
            return $this->sendError('Unauthorized.', ['error' => 'Unauthorized'], 401);
        }
    }

    /**
     * Logout user.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout()
    {
        Auth::user()->tokens()->delete();

        return $this->sendResponse([], 'User logged out successfully.');
    }

    /**
     * Get user profile.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function profile()
    {
        $user = Auth::user();

        return $this->sendResponse($user, 'User profile retrieved successfully.');
    }

    /**
     * Login or register with Google.
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function googleLogin(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'id_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return $this->sendError('Validation Error.', $validator->errors(), 422);
        }

        try {
            // Here we'll receive the ID token from the Flutter app and validate it
            // In a production environment, you should validate the ID token with Google
            $idToken = $request->id_token;

            // For this implementation, we'll use Socialite to verify the Google user
            // Since we're receiving the token from the frontend, we'll use a different approach
            // where we'll validate the token against Google's APIs directly

            $googleUser = $this->verifyGoogleToken($idToken);

            if (!$googleUser) {
                return $this->sendError('Invalid Google token.', ['error' => 'Unauthorized'], 401);
            }

            // Check if user already exists
            $user = User::where('email', $googleUser['email'])->first();

            if (!$user) {
                // Create new user if doesn't exist
                $user = User::create([
                    'name' => $googleUser['name'],
                    'email' => $googleUser['email'],
                    'password' => '', // No password for Google auth users
                ]);

                $user->assignRole('user');
            }

            // Generate Sanctum token
            $token = $user->createToken('Google Personal Access Token')->plainTextToken;

            $success = [
                'token' => $token,
                'name' => $user->name,
                'email' => $user->email,
            ];

            return $this->sendResponse($success, 'User login with Google successfully.');

        } catch (\Exception $e) {
            Log::error('Google login error: ' . $e->getMessage());
            return $this->sendError('Google login failed.', ['error' => $e->getMessage()], 500);
        }
    }

    /**
     * Verifies the Google ID token.
     *
     * @param string $idToken
     * @return array|null
     */
    private function verifyGoogleToken($idToken)
    {
        $client = new \Google_Client(['client_id' => env('GOOGLE_CLIENT_ID')]);
        $payload = $client->verifyIdToken($idToken);

        if ($payload) {
            return [
                'email' => $payload['email'],
                'name' => $payload['name'],
                'id' => $payload['sub'], // Google user ID
            ];
        }

        return null;
    }
}
