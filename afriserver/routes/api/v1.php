<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;


Route::prefix('auth')->name('auth.')->group(function (): void {
    Route::post('register', [AuthController::class, 'register'])->name('register');
    Route::post('login', [AuthController::class, 'login'])->name('login');

    // Seul un refresh token (ability 'issue-access-token') peut appeler ceci
    Route::middleware(['auth:sanctum', 'abilities:issue-access-token'])->group(function (): void {
        Route::post('refresh-token', [AuthController::class, 'refreshToken'])->name('refresh-token');
    });

    // Seul un access token (ability 'access-api') peut appeler ces routes
    Route::middleware(['auth:sanctum', 'abilities:access-api', 'check.token.expiration'])->group(function (): void {
        Route::post('logout', [AuthController::class, 'logout'])->name('logout');
        Route::get('me', [AuthController::class, 'me'])->name('me');
        Route::put('password', [AuthController::class, 'changePassword'])->name('password');
    });
});

Route::middleware(['auth:sanctum', 'abilities:access-api', 'check.token.expiration'])->group(function (): void {
    Route::get('/user', [UserController::class, 'show'])->name('user.show');
});