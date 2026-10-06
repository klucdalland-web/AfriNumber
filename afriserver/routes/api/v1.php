<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DeviceController;
use App\Http\Controllers\Api\V1\NotificationController;
use App\Http\Controllers\Api\V1\ObservabilityController;
use App\Http\Controllers\Api\V1\OrganisationController;
use App\Http\Controllers\Api\V1\PaysController;
use App\Http\Controllers\Api\V1\PieceIdentiteController;
use App\Http\Controllers\Api\V1\PlanController;
use App\Http\Controllers\Api\V1\ProfileVerificationController;
use App\Http\Controllers\Api\V1\SubscriptionController;
use App\Http\Controllers\Api\V1\TypeNotificationController;
use App\Http\Controllers\Api\V1\TypePieceIdentiteController;
use App\Http\Controllers\Api\V1\UserController;
use Illuminate\Support\Facades\Route;

// Référentiel organisations / pays — public (inscription)
Route::get('/organisations', [OrganisationController::class, 'index'])->name('organisations.index');
Route::get('/organisations/{organisation}', [OrganisationController::class, 'show'])->name('organisations.show');
Route::get('/organisations/{organisation}/pays', [OrganisationController::class, 'pays'])->name('organisations.pays');

Route::get('/pays', [PaysController::class, 'index'])->name('pays.index');
Route::get('/pays/{pay}', [PaysController::class, 'show'])->name('pays.show');

Route::prefix('auth')->name('auth.')->group(function (): void {
    Route::post('register', [AuthController::class, 'register'])->name('register')->middleware('throttle:register');
    Route::post('login', [AuthController::class, 'login'])->name('login')->middleware('throttle:login');
    Route::post('verify-otp', [AuthController::class, 'verifyOtp'])
        ->name('verify-otp')
        ->middleware('throttle:10,1');

    Route::post('resend-otp', [AuthController::class, 'resendOtp'])
        ->name('resend-otp')
        ->middleware('throttle:5,1');

    Route::post('forgot-password', [AuthController::class, 'forgotPassword'])
        ->name('forgot-password')
        ->middleware('throttle:3,1');

    Route::post('reset-password', [AuthController::class, 'resetPassword'])
        ->name('reset-password')
        ->middleware('throttle:5,1');

    // Seul un refresh token (ability 'issue-access-token') peut appeler ceci
    Route::middleware(['auth:sanctum', 'abilities:issue-access-token'])->group(function (): void {
        Route::post('refresh-token', [AuthController::class, 'refreshToken'])->name('refresh-token');
    });

    // Seul un access token (ability 'access-api') peut appeler ces routes
    Route::middleware(['auth:sanctum', 'abilities:access-api', 'check.token.expiration'])->group(function (): void {
        Route::post('logout', [AuthController::class, 'logout'])->name('logout');
        Route::get('me', [AuthController::class, 'me'])->name('me');
        Route::put('password', [AuthController::class, 'changePassword'])->name('password')->middleware('throttle:5,1');
    });
});

Route::middleware(['auth:sanctum', 'abilities:access-api', 'check.token.expiration'])->group(function (): void {
    Route::get('/user', [UserController::class, 'show'])->name('user.show');
    Route::get('/plans', [PlanController::class, 'index'])->name('plans.index');
    Route::get('/abonnements', [SubscriptionController::class, 'index'])->name('abonnements.index');
    Route::get('/abonnement', [SubscriptionController::class, 'show'])->name('abonnement.show');

    Route::get('/devices', [DeviceController::class, 'index'])->name('devices.index');
    Route::post('/devices/fcm-token', [DeviceController::class, 'updateFcmToken'])->name('devices.fcm-token');
    Route::delete('/devices/others', [DeviceController::class, 'destroyOthers'])->name('devices.destroy-others');
    Route::delete('/devices/{device}', [DeviceController::class, 'destroy'])->name('devices.destroy');

    Route::get('/observability/logs', [ObservabilityController::class, 'index'])->name('observability.logs');

    // Types de pièces (référentiel)
    Route::get('/type-piece-identites', [TypePieceIdentiteController::class, 'index'])->name('type-piece-identites.index');
    Route::get('/type-piece-identites/{typePieceIdentite}', [TypePieceIdentiteController::class, 'show'])->name('type-piece-identites.show');

    // Types de notifications (référentiel)
    Route::get('/type-notifications', [TypeNotificationController::class, 'index'])->name('type-notifications.index');
    Route::get('/type-notifications/{typeNotification}', [TypeNotificationController::class, 'show'])->name('type-notifications.show');

    // Inbox notifications (compte authentifié uniquement)
    Route::get('/notifications', [NotificationController::class, 'index'])->name('notifications.index');
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount'])->name('notifications.unread-count');
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead'])->name('notifications.read-all');
    Route::get('/notifications/{notification}', [NotificationController::class, 'show'])->name('notifications.show');
    Route::post('/notifications/{notification}/read', [NotificationController::class, 'markAsRead'])->name('notifications.read');
    Route::delete('/notifications/{notification}', [NotificationController::class, 'destroy'])->name('notifications.destroy');

    // Pièces d'identité user — logique métier déléguée à Node.js
    Route::get('/pieces', [PieceIdentiteController::class, 'index'])->name('pieces.index');
    Route::post('/pieces', [PieceIdentiteController::class, 'store'])->name('pieces.store');
    Route::get('/pieces/{piece}', [PieceIdentiteController::class, 'show'])->name('pieces.show');
    Route::put('/pieces/{piece}', [PieceIdentiteController::class, 'update'])->name('pieces.update');
    Route::delete('/pieces/{piece}', [PieceIdentiteController::class, 'destroy'])->name('pieces.destroy');
    Route::post('/pieces/{piece}/fichiers', [PieceIdentiteController::class, 'storeFichiers'])->name('pieces.fichiers.store');
    Route::get('/pieces/{piece}/statut', [PieceIdentiteController::class, 'statut'])->name('pieces.statut');

    // Route pour le Mobile (Nécessite que l'utilisateur soit connecté à son appli)

    Route::middleware('auth:sanctum')->group(function (): void {
        Route::post('/verifier/init', [ProfileVerificationController::class, 'initialiserVerification']);
        Route::get('/verifier/status', [ProfileVerificationController::class, 'statutVerification']);
        Route::get('/verifier/status/{profile_id}', [ProfileVerificationController::class, 'statutVerificationParId']);
    });
});
