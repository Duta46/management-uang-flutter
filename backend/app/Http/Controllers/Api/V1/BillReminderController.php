<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\BillReminder;
use App\Services\BillReminderService;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class BillReminderController extends Controller
{
    protected BillReminderService $billReminderService;

    public function __construct(BillReminderService $billReminderService)
    {
        $this->billReminderService = $billReminderService;
    }

    /**
     * Display a listing of the resource.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }

            $billReminders = BillReminder::where('user_id', $user->id)
                ->where('is_active', true) // Hanya tampilkan pengingat tagihan yang aktif
                ->orderBy('due_date', 'asc')
                ->orderBy('created_at', 'desc')
                ->paginate(15);

            // Tambahkan status ke setiap bill reminder
            foreach ($billReminders as $billReminder) {
                $billReminder->status = $this->billReminderService->getBillReminderStatus($billReminder);
                $billReminder->days_until_due = \Carbon\Carbon::today()->diffInDays(\Carbon\Carbon::parse($billReminder->due_date), false);
            }

            return response()->json([
                'success' => true,
                'data' => $billReminders,
                'message' => 'Bill reminders retrieved successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'An error occurred while retrieving bill reminders: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'amount' => 'required|numeric|min:0',
            'due_date' => 'required|date',
            'frequency' => 'required|in:monthly,weekly,yearly,one_time',
            'is_paid' => 'boolean',
            'is_active' => 'boolean',
            'next_due_date' => 'date'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        $billReminder = BillReminder::create([
            'user_id' => $user->id,
            'name' => $request->name,
            'description' => $request->description,
            'amount' => $request->amount,
            'due_date' => $request->due_date,
            'frequency' => $request->frequency,
            'is_paid' => $request->is_paid ?? false,
            'is_active' => $request->is_active ?? true, // Secara default aktif saat ditambahkan
            'next_due_date' => $request->next_due_date ?? $request->due_date
        ]);

        // Tambahkan status ke bill reminder
        $billReminder->status = $this->billReminderService->getBillReminderStatus($billReminder);
        $billReminder->days_until_due = \Carbon\Carbon::today()->diffInDays(\Carbon\Carbon::parse($billReminder->due_date), false);

        return response()->json([
            'success' => true,
            'data' => $billReminder,
            'message' => 'Bill reminder created successfully'
        ], 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id, Request $request): JsonResponse
    {
        $user = $request->user();

        $billReminder = BillReminder::where('user_id', $user->id)
            ->where('is_active', true) // Hanya cari pengingat tagihan yang aktif
            ->find($id);

        if (!$billReminder) {
            return response()->json([
                'success' => false,
                'message' => 'Bill reminder not found or inactive'
            ], 404);
        }

        // Tambahkan status ke bill reminder
        $billReminder->status = $this->billReminderService->getBillReminderStatus($billReminder);
        $billReminder->days_until_due = \Carbon\Carbon::today()->diffInDays(\Carbon\Carbon::parse($billReminder->due_date), false);

        return response()->json([
            'success' => true,
            'data' => $billReminder,
            'message' => 'Bill reminder retrieved successfully'
        ]);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'string|max:255',
            'description' => 'nullable|string',
            'amount' => 'numeric|min:0',
            'due_date' => 'date',
            'frequency' => 'in:monthly,weekly,yearly,one_time',
            'is_paid' => 'boolean',
            'is_active' => 'boolean',
            'next_due_date' => 'date'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = $request->user();

        $billReminder = BillReminder::where('user_id', $user->id)->find($id);

        if (!$billReminder) {
            return response()->json([
                'success' => false,
                'message' => 'Bill reminder not found'
            ], 404);
        }

        $billReminder->update($request->all());

        // Tambahkan status ke bill reminder
        $billReminder->status = $this->billReminderService->getBillReminderStatus($billReminder);
        $billReminder->days_until_due = \Carbon\Carbon::today()->diffInDays(\Carbon\Carbon::parse($billReminder->due_date), false);

        return response()->json([
            'success' => true,
            'data' => $billReminder,
            'message' => 'Bill reminder updated successfully'
        ]);
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id, Request $request): JsonResponse
    {
        $user = $request->user();

        $billReminder = BillReminder::where('user_id', $user->id)->find($id);

        if (!$billReminder) {
            return response()->json([
                'success' => false,
                'message' => 'Bill reminder not found'
            ], 404);
        }

        $billReminder->delete();

        return response()->json([
            'success' => true,
            'message' => 'Bill reminder deleted successfully'
        ]);
    }

    /**
     * Get bill reminders with status
     */
    public function getBillRemindersWithStatus(Request $request): JsonResponse
    {
        $user = $request->user();

        $billReminders = $this->billReminderService->getBillRemindersWithStatus($user->id, true); // Hanya yang aktif

        return response()->json([
            'success' => true,
            'data' => $billReminders,
            'message' => 'Bill reminders with status retrieved successfully'
        ]);
    }

    /**
     * Check and renew due bills
     */
    public function checkAndRenewDueBills(Request $request): JsonResponse
    {
        $user = $request->user();

        $billReminders = BillReminder::where('user_id', $user->id)
            ->where('is_active', true)
            ->get();

        $renewedBills = [];

        foreach ($billReminders as $billReminder) {
            if ($this->billReminderService->shouldRenewBill($billReminder)) {
                $renewedBill = $this->billReminderService->renewBill($billReminder);
                $renewedBills[] = $renewedBill;
            }
        }

        return response()->json([
            'success' => true,
            'data' => $renewedBills,
            'message' => count($renewedBills) . ' bills renewed successfully'
        ]);
    }
}
