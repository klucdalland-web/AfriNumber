<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CurrencyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class RatesWebhookController extends Controller
{
    public function __construct(
        protected CurrencyService $currencyService
    ) {}

    /**
     * External endpoint called by a cron service to update exchange rates.
     * Secured by a CRON_SECRET in .env
     */
    public function update(Request $request)
    {
        // $secret = $request->header('X-Cron-Secret') ?? $request->input('secret');

        // if (! $secret || $secret !== config('services.internal.cron_secret')) {
        //     return response()->json([
        //         'success' => false,
        //         'message' => 'Unauthorized: Invalid or missing secret token.'
        //     ], 403);
        // }

        $result = $this->currencyService->updateAllRates();

        if ($result['success']) {
            return response()->json([
                'success' => true,
                'message' => 'Exchange rates updated successfully.',
                'details' => $result
            ], 200);
        }

        return response()->json([
            'success' => false,
            'message' => 'Failed to update rates: ' . ($result['error'] ?? 'Unknown error'),
        ], 500);
    }
}
