<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')
    ->name('v1.')
    ->middleware('x-api-key-v1')
    ->group(base_path('routes/api/v1.php'))
    ;
