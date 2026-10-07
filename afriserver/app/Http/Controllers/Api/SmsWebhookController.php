<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SmsMessage;
use App\Models\UserNumber;
use App\Services\KycNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class SmsWebhookController extends Controller
{
    public function __construct(
        protected KycNotificationService $notifier
    ) {}

    /**
     * Webhook endpoint called by VerifiedCore when a new SMS is received.
     */
    public function handleVerifiedCore(Request $request)
    {
        try {
            // In a real scenario, we would verify a signature here
            $data = $request->all();

            // We identify the number by the provider's ID or the phone number itself
            $phoneNumber = $data['phone_number'] ?? null;
            $sender = $data['sender'] ?? 'Unknown';
            $content = $data['content'] ?? '';

            if (! $phoneNumber) {
                return response()->json(['status' => 'error', 'message' => 'No phone number provided'], 400);
            }

            $userNumber = UserNumber::where('phone_number', $phoneNumber)->first();

            if (! $userNumber) {
                return response()->json(['status' => 'error', 'message' => 'Number not found in our system'], 404);
            }

            // Save the message
            $message = SmsMessage::create([
                'user_number_id' => $userNumber->id,
                'sender' => $sender,
                'content' => $content,
                'received_at' => now(),
            ]);

            // Trigger Push Notification to the user
            $this->notifier->notifySmsReceived($userNumber->user, $message);

            return response()->json(['status' => 'success'], 200);
        } catch (\Exception $e) {
            Log::error('SmsWebhook Error: ' . $e->getMessage());
            return response()->json(['status' => 'error', 'message' => 'Internal server error'], 500);
        }
    }

    /**
     * Simulation route for Mock mode.
     * Allows simulating an incoming SMS for a specific user.
     */
    public function simulate(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'content' => 'required|string',
            'sender' => 'nullable|string',
        ]);

        $user = \App\Models\User::find($request->user_id);
        $userNumber = $user->userNumbers()->first();

        if (! $userNumber) {
            return response()->json(['success' => false, 'message' => 'User has no active numbers to receive SMS.'], 404);
        }

        $message = SmsMessage::create([
            'user_number_id' => $userNumber->id,
            'sender' => $request->sender ?? '+123456789',
            'content' => $request->content,
            'received_at' => now(),
        ]);

        // Trigger Push Notification
        $this->notifier->notifySmsReceived($user, $message);

        return response()->json([
            'success' => true,
            'message' => 'Simulated SMS sent successfully!',
            'data' => $message
        ]);
    }
}
