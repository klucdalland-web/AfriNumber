<?php

use App\Http\Controllers\API\NumberController;
use App\Http\Controllers\Api\V1\ProfileVerificationController;
use Illuminate\Support\Facades\Route;

Route::get('/numbers/search', [NumberController::class, 'search']);
Route::post('/numbers/buy', [NumberController::class, 'buy']);

Route::prefix('v1')
    ->name('v1.')
    ->middleware(['x-api-key-v1', 'check.device.session', 'observability'])
    ->group(base_path('routes/api/v1.php'));

// Route secrète pour Express (Pas de middleware Sanctum ici car c'est votre serveur Node qui appelle)
Route::post('/v1/express/upload-complete', [ProfileVerificationController::class, 'notifierUploadTermine']);

// Route secrète pour n8n (HMAC sur profile_id via header X-Signature)
Route::get('/v1/n8n/profiles/{profile_id}', [ProfileVerificationController::class, 'show']);
