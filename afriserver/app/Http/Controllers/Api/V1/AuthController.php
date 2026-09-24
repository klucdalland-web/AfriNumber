<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\ChangePasswordRequest;
use App\Http\Requests\Api\V1\Auth\ForgotPasswordRequest;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Requests\Api\V1\Auth\ResetPasswordRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\PasswordResetCode;
use App\Models\Pays;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\TypeUser;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;
use Throwable;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();

        try {
            $result = DB::transaction(function () use ($validated, $request) {
                $typeUserId = TypeUser::query()->where('code', 'user')->value('id');

                $contrieId = $validated['contrie_id'];

                $pays = Pays::query()->where('id', $contrieId)->first();

                if (! $pays || ! $pays->organisation_id) {
                    throw ValidationException::withMessages([
                        'contrie_id' => ['Le pays sélectionné est invalide.'],
                    ]);
                }

                $user = User::query()->create([
                    'name' => $validated['name'],
                    'email' => $validated['email'],
                    'first_name' => $validated['first_name'],
                    'phone_number' => $validated['phone_number'],
                    'password' => Hash::make($validated['password']),
                    'type_user_id' => $typeUserId,
                    'statut' => 'actif',
                    'status_valide' => 'non_valide',
                    'organisation_id' => $pays->organisation_id,
                ]);

                $user->load(['typeUser', 'organisation']);

                $tokens = $this->registerDeviceAndTokens($user, $validated, $request);

                return array_merge(['user' => UserResource::make($user)], $tokens);
            });

            return ApiResponse::success('Inscription réussie.', $result, 201);
        } catch (ValidationException $e) {
            throw $e;
        } catch (Throwable $e) {
            Log::error('Erreur lors de l\'inscription.', [
                'message' => $e->getMessage(),
                'email' => $validated['email'] ?? null,
            ]);

            return ApiResponse::error('Une erreur est survenue lors de l\'inscription.', null, 500);
        }
    }

   public function login(LoginRequest $request): JsonResponse
{
    $validated = $request->validated();
    $login = $validated['email'];

    $user = User::query()
        ->where(function ($query) use ($login): void {
            $query->where('email', $login)
                ->orWhere('phone_number', $login);
        })
        ->first();

    // Vérifie si le compte est actuellement verrouillé
   if ($user && $user->locked_until && $user->locked_until->isFuture()) {
    $minutesLeft = (int) ceil(now()->diffInMinutes($user->locked_until));

    return ApiResponse::error(
        "Compte temporairement verrouillé suite à plusieurs tentatives échouées. Réessayez dans {$minutesLeft} minute(s).",
        ['locked_minutes_left' => $minutesLeft],
        423
    );
}

    if (! $user || ! Hash::check($validated['password'], $user->password)) {
        if ($user) {
            $this->registerFailedAttempt($user);
        }

        throw ValidationException::withMessages([
            'login' => ['Identifiants incorrects.'],
        ]);
    }

    // Connexion réussie : réinitialise le compteur d'échecs
    if ($user->failed_login_attempts > 0 || $user->locked_until) {
        $user->update([
            'failed_login_attempts' => 0,
            'locked_until' => null,
        ]);
    }

    if ($user->statut !== 'actif') {
        return ApiResponse::error('Compte non actif.', null, 403);
    }

    try {
        $result = DB::transaction(function () use ($user, $validated, $request) {
            $user->load(['typeUser', 'organisation']);

            $tokens = $this->registerDeviceAndTokens($user, $validated, $request);

            return array_merge(['user' => UserResource::make($user)], $tokens);
        });

        return ApiResponse::success('Connexion réussie.', $result);
    } catch (ValidationException $e) {
        throw $e;
    } catch (Throwable $e) {
        Log::error('Erreur lors de la connexion.', [
            'message' => $e->getMessage(),
            'user_id' => $user->id,
        ]);

        return ApiResponse::error('Une erreur est survenue lors de la connexion.', null, 500);
    }
}

/**
 * Incrémente le compteur d'échecs et verrouille le compte si le seuil est atteint.
 */
    private function registerFailedAttempt(User $user): void
    {
        $attempts = $user->failed_login_attempts + 1;

        $data = ['failed_login_attempts' => $attempts];

        $lockoutMinutes = match (true) {
            $attempts >= 15 => 1440, // 24h
            $attempts >= 10 => 15,
            $attempts >= 5 => 5,
            default => null,
        };

        if ($lockoutMinutes !== null) {
            $data['locked_until'] = now()->addMinutes($lockoutMinutes);
        }

        $user->update($data);
    }

    /**
 * Enregistre/actualise le device, la session et le token FCM,
 * puis génère un nouveau couple access/refresh token.
 *
 * @return array<string, mixed>
 */
    private function registerDeviceAndTokens(User $user, array $validated, Request $request): array
    {
        $platform = Platform::query()
            ->whereRaw('LOWER(label) = ?', [strtolower($validated['platform'])])
            ->first();

        if (! $platform) {
            throw ValidationException::withMessages([
                'platform' => ['Application invalide. Veuillez changer de plateforme.'],
            ]);
        }

        // Désactive toute session d'un AUTRE utilisateur sur ce même appareil physique
        $otherUsersDevices = Device::query()
            ->where('identifier', $validated['device_id'])
            ->where('user_id', '!=', $user->id)
            ->get();

        foreach ($otherUsersDevices as $otherDevice) {
            $otherDevice->update(['actif' => false]);

            SessionUser::query()
                ->where('device_id', $otherDevice->id)
                ->update(['is_active' => false]);

            $deviceName = $otherDevice->name;

            $otherDevice->user->tokens()
                ->where(function ($query) use ($deviceName): void {
                    $query->where('name', $deviceName . '-access')
                        ->orWhere('name', $deviceName . '-refresh');
                })
                ->delete();
        }

        $device = Device::query()->updateOrCreate(
            [
                'user_id' => $user->id,
                'identifier' => $validated['device_id'],
            ],
            [
                'platform_id' => $platform->id,
                'name' => $validated['device_name'] ?? 'Appareil',
                'model' => $validated['device_model'],
                'os_version' => $validated['os_version'],
                'actif' => true,
                'last_used_at' => now(),
            ]
        );

        $geoService = new \App\Services\GeoLocationService();
        $ip = $this->getClientIp($request);
        $geo = $geoService->getGeoFromIp($ip);

        SessionUser::query()->updateOrCreate(
            ['device_id' => $device->id],
            [
                'user_id' => $user->id,
                'user_agent' => $request->userAgent(),
                'ip_address' => $ip ?? $request->ip(),
                'country' => $geo['country'] ?? null,
                'city' => $geo['city'] ?? null,
                'region' => $geo['region'] ?? null,
                'timezone' => $geo['timezone'] ?? null,
                'latitude' => $geo['latitude'] ?? null,
                'internet_provider' => $geo['internet_provider'] ?? null,
                'network_type' => $geo['network_type'] ?? null,
                'last_activity' => now(),
                'is_active' => true,
            ]
        );

        DeviceTokenFcm::query()
            ->where('token', $validated['fcm_token'])
            ->where('device_id', '!=', $device->id)
            ->delete();

        DeviceTokenFcm::query()->updateOrCreate(
            ['device_id' => $device->id],
            [
                'token' => $validated['fcm_token'],
                'actif' => true,
            ]
        );

        $deviceName = $validated['device_name'] ?? 'api';

        $accessToken = $user->createToken($deviceName . '-access', ['access-api']);
        $accessExpiresAt = Carbon::now()->addDay();

        $refreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
        $refreshExpiresAt = Carbon::now()->addDays(30);

        return [
            'access_token' => $accessToken->plainTextToken,
            'access_token_expires_at' => $accessExpiresAt->toIso8601String(),
            'refresh_token' => $refreshToken->plainTextToken,
            'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
            'token_type' => 'Bearer',
        ];
    }

    public function refreshToken(Request $request): JsonResponse
    {
        try {
            $refreshToken = $request->user()->currentAccessToken();

            if (! $request->user()->tokenCan('issue-access-token')) {
                return ApiResponse::error('Token invalide pour cette action.', null, 403);
            }

            if ($refreshToken->created_at->addDays(30)->isPast()) {
                $refreshToken->delete();

                return ApiResponse::error('Session expirée, veuillez vous reconnecter.', null, 401);
            }

            $result = DB::transaction(function () use ($request, $refreshToken) {
                $user = $request->user();
                $deviceName = str_replace('-refresh', '', $refreshToken->name);

                $newAccessToken = $user->createToken($deviceName . '-access', ['access-api']);
                $accessExpiresAt = Carbon::now()->addDay();

                $refreshToken->delete();
                $newRefreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
                $refreshExpiresAt = Carbon::now()->addDays(30);

                return [
                    'access_token' => $newAccessToken->plainTextToken,
                    'access_token_expires_at' => $accessExpiresAt->toIso8601String(),
                    'refresh_token' => $newRefreshToken->plainTextToken,
                    'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
                    'token_type' => 'Bearer',
                ];
            });

            return ApiResponse::success('Token actualisé.', $result);
        } catch (Throwable $e) {
            Log::error('Erreur lors du refresh du token.', [
                'message' => $e->getMessage(),
                'user_id' => $request->user()?->id,
            ]);

            return ApiResponse::error('Une erreur est survenue lors de l\'actualisation du token.', null, 500);
        }
    }

    public function logout(Request $request): JsonResponse
    {
        try {
            $user = $request->user();
            $currentToken = $user->currentAccessToken();
            $deviceName = str_replace(['-access', '-refresh'], '', $currentToken->name);

            $user->tokens()
                ->where(function ($query) use ($deviceName): void {
                    $query->where('name', $deviceName . '-access')
                        ->orWhere('name', $deviceName . '-refresh');
                })
                ->delete();

            return ApiResponse::success('Déconnexion réussie.');
        } catch (Throwable $e) {
            Log::error('Erreur lors de la déconnexion.', [
                'message' => $e->getMessage(),
                'user_id' => $request->user()?->id,
            ]);

            return ApiResponse::error('Une erreur est survenue lors de la déconnexion.', null, 500);
        }
    }

    public function me(Request $request): JsonResponse
    {
        $user = $request->user()->load(['typeUser', 'organisation']);

        return ApiResponse::success(null, [
            'user' => UserResource::make($user),
        ]);
    }

    public function changePassword(ChangePasswordRequest $request): JsonResponse
    {
        $user = $request->user();
        $validated = $request->validated();

        try {
            $result = DB::transaction(function () use ($user, $validated) {
                $user->update([
                    'password' => Hash::make($validated['password']),
                ]);

                $currentToken = $user->currentAccessToken();
                $deviceName = $currentToken instanceof PersonalAccessToken
                    ? str_replace(['-access', '-refresh'], '', $currentToken->name)
                    : 'api';

                $user->tokens()->delete();

                $newAccessToken = $user->createToken($deviceName . '-access', ['access-api']);
                $accessExpiresAt = Carbon::now()->addDay();

                $newRefreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
                $refreshExpiresAt = Carbon::now()->addDays(30);

                return [
                    'access_token' => $newAccessToken->plainTextToken,
                    'access_token_expires_at' => $accessExpiresAt->toIso8601String(),
                    'refresh_token' => $newRefreshToken->plainTextToken,
                    'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
                    'token_type' => 'Bearer',
                ];
            });

            return ApiResponse::success('Mot de passe modifié avec succès.', $result);
        } catch (Throwable $e) {
            Log::error('Erreur lors du changement de mot de passe.', [
                'message' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return ApiResponse::error('Une erreur est survenue lors du changement de mot de passe.', null, 500);
        }
    }
     private function getClientIp(Request $request): string
    {
        $ip =
            $request->header('CF-Connecting-IP') ??
            $request->header('X-Real-IP') ??
            $request->header('X-Forwarded-For');

        if ($ip && str_contains($ip, ',')) {
            $ip = explode(',', $ip)[0];
        }

        return $ip ?: $request->ip();
    }

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
{
    $validated = $request->validated();

    $user = User::query()
        ->when($validated['email'] ?? null, fn ($query, $email) => $query->where('email', $email))
        ->when($validated['phone_number'] ?? null, fn ($query, $phone) => $query->where('phone_number', $phone))
        ->first();

    $genericResponse = ApiResponse::success('Si ce compte existe, un code de réinitialisation a été envoyé.');

    if (! $user) {
        return $genericResponse;
    }

    $code = (string) random_int(100000, 999999);
    $code=123456;

    PasswordResetCode::query()
        ->when($validated['email'] ?? null, fn ($query, $email) => $query->where('email', $email))
        ->when($validated['phone_number'] ?? null, fn ($query, $phone) => $query->where('phone_number', $phone))
        ->delete();

    PasswordResetCode::query()->create([
        'email' => $validated['email'] ?? null,
        'phone_number' => $validated['phone_number'] ?? null,
        'code' => Hash::make($code),
        'expires_at' => now()->addMinutes(15),
    ]);

    // TODO : envoyer $code par email (si 'email' fourni) ou SMS (si 'phone_number' fourni)

    Log::info('Code de réinitialisation généré.', [
        'email' => $validated['email'] ?? null,
        'phone_number' => $validated['phone_number'] ?? null,
    ]);

    return $genericResponse;
}

public function resetPassword(ResetPasswordRequest $request): JsonResponse
{
    $validated = $request->validated();

    $resetCode = PasswordResetCode::query()
        ->when($validated['email'] ?? null, fn ($query, $email) => $query->where('email', $email))
        ->when($validated['phone_number'] ?? null, fn ($query, $phone) => $query->where('phone_number', $phone))
        ->latest()
        ->first();

    if (! $resetCode || ! Hash::check($validated['code'], $resetCode->code)) {
        throw ValidationException::withMessages([
            'code' => ['Code invalide.'],
        ]);
    }

    if ($resetCode->expires_at->isPast()) {
        $resetCode->delete();

        throw ValidationException::withMessages([
            'code' => ['Ce code a expiré. Veuillez en demander un nouveau.'],
        ]);
    }

    $user = User::query()
        ->when($validated['email'] ?? null, fn ($query, $email) => $query->where('email', $email))
        ->when($validated['phone_number'] ?? null, fn ($query, $phone) => $query->where('phone_number', $phone))
        ->first();

    if (! $user) {
        throw ValidationException::withMessages([
            'email' => ['Compte introuvable.'],
        ]);
    }

    try {
        DB::transaction(function () use ($user, $validated, $resetCode) {
            $user->update([
                'password' => Hash::make($validated['password']),
                'failed_login_attempts' => 0,
                'locked_until' => null,
            ]);

            $user->tokens()->delete();

            $resetCode->delete();
        });

        return ApiResponse::success('Mot de passe réinitialisé avec succès. Vous pouvez maintenant vous reconnecter.');
    } catch (Throwable $e) {
        Log::error('Erreur lors de la réinitialisation du mot de passe.', [
            'message' => $e->getMessage(),
        ]);

        return ApiResponse::error('Une erreur est survenue lors de la réinitialisation.', null, 500);
    }
}
}