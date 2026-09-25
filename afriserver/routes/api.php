<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\NumberController;

Route::get('/numbers/search', [NumberController::class, 'search']);
Route::post('/numbers/buy', [NumberController::class, 'buy']);

Route::prefix('v1')
    ->name('v1.')
    ->middleware(['x-api-key-v1', 'check.device.session'])
    ->group(base_path('routes/api/v1.php'))
    ;
