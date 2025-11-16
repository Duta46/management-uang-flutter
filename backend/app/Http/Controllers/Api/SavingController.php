<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreSavingRequest;
use App\Http\Requests\UpdateSavingRequest;
use App\Models\Saving;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class SavingController extends BaseController
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $user = Auth::user();
        
        // Check if user has admin role
        if ($user->hasRole('admin')) {
            $savings = Saving::with('user')->paginate(10);
        } else {
            $savings = $user->savings()->paginate(10);
        }

        return $this->sendResponse($savings, 'Savings retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(StoreSavingRequest $request)
    {
        $user = Auth::user();
        $input = $request->validated();
        $input['user_id'] = $user->id;

        $saving = Saving::create($input);

        return $this->sendResponse($saving, 'Saving created successfully.', 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Saving $saving)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the saving
        if (!$user->hasRole('admin') && $saving->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        return $this->sendResponse($saving, 'Saving retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(UpdateSavingRequest $request, Saving $saving)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the saving
        if (!$user->hasRole('admin') && $saving->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $saving->update($request->validated());

        return $this->sendResponse($saving, 'Saving updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Saving $saving)
    {
        $user = Auth::user();

        // Check if user has admin role or owns the saving
        if (!$user->hasRole('admin') && $saving->user_id !== $user->id) {
            return $this->sendError('Unauthorized.', [], 403);
        }

        $saving->delete();

        return $this->sendResponse([], 'Saving deleted successfully.');
    }
}
