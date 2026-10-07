<?php

use App\Http\Controllers\API\NumberController;
use App\Http\Controllers\Api\V1\ProfileVerificationController;
use Illuminate\Support\Facades\Route;

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/numbers/search', [NumberController::class, 'search']);
    Route::post('/numbers/buy', [NumberController::class, 'buy']);
    Route::get('/numbers/my', [NumberController::class, 'myNumbers']);
    Route::get('/numbers/messages', [NumberController::class, 'myMessages']);

    Route::get('/wallet/balance', [\App\Http\Controllers\Api\WalletController::class, 'balance']);
    Route::post('/wallet/topup', [\App\Http\Controllers\Api\WalletController::class, 'topUp']);
});

// Internal / Webhooks
Route::post('/webhooks/verifiedcore/sms', [\App\Http\Controllers\Api\SmsWebhookController::class, 'handleVerifiedCore']);
Route::post('/webhooks/simulate/sms', [\App\Http\Controllers\Api\SmsWebhookController::class, 'simulate']);
Route::post('/internal/update-rates', [\App\Http\Controllers\Api\RatesWebhookController::class, 'update']);

Route::prefix('v1')
    ->name('v1.')
    ->middleware(['x-api-key-v1', 'check.device.session', 'observability'])
    ->group(base_path('routes/api/v1.php'));

// Route secrète pour Express (Pas de middleware Sanctum ici car c'est le serveur Node qui appelle)
Route::post('/v1/express/upload-complete', [ProfileVerificationController::class, 'notifierUploadTermine']);

// Route secrète pour n8n (HMAC sur profile_id via header X-Signature)
Route::get('/v1/n8n/profiles/{profile_id}', [ProfileVerificationController::class, 'show']);


// 🟢 Route appelée par les nœuds HTTP violets de n8n
Route::post('/v1/n8n/kyc-callback', [ProfileVerificationController::class, 'traiterVerdictN8N']);

// Cron / n8n : drain des campagnes notifications (HMAC sur "process-notification-campaigns")
Route::post('/v1/internal/process-notification-campaigns', \App\Http\Controllers\Api\V1\ProcessNotificationCampaignsController::class);
