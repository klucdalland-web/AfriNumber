<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\ChangePasswordRequest;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\Pays;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\TypeUser;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;
use Laravel\Sanctum\PersonalAccessToken;

class AuthController extends Controller
{
    public function register(RegisterRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $typeUserId = TypeUser::query()->where('code', 'user')->value('id');

        $contrieId = $validated['contrie_id'] ;

        $organisation_id=Pays::query()->where('id', $contrieId)->firstOrFail()->organisation_id;

        if( !$organisation_id){
            return ApiResponse::error('Le pays sélectionné est invalide.', null, 400);
        }

        $user = User::query()->create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'first_name' => $validated['first_name'] ,

            'phone_number' => $validated['phone_number'],
            'password' => $validated['password'],
            'type_user_id' => $typeUserId,
            'statut' => 'actif',
            'status_valide' => 'non_valide',
            'organisation_id' => $organisation_id,
        ]);

        $user->load(['typeUser', 'organisation']);


       $deviceName = $validated['device_name'] ?? 'api';

        $accessToken = $user->createToken($deviceName . '-access', ['access-api']);
        $accessExpiresAt = Carbon::now()->addDay();

        $refreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
        $refreshExpiresAt = Carbon::now()->addDays(30);

        return ApiResponse::success('Inscription réussie.', [
            'user' => UserResource::make($user),
            'access_token' => $accessToken->plainTextToken,
            'access_token_expires_at' => $accessExpiresAt->toIso8601String(),
            'refresh_token' => $refreshToken->plainTextToken,
            'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
            'token_type' => 'Bearer',
        ], 201);
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

        if (! $user || ! Hash::check($validated['password'], $user->password)) {
            throw ValidationException::withMessages([
                'login' => ['Identifiants incorrects.'],
            ]);
        }

        if ($user->statut !== 'actif') {
            return ApiResponse::error('Compte non actif.', null, 403);
        }

        $user->load(['typeUser', 'organisation']);

        $platform = Platform::query()
            ->whereRaw('LOWER(label) = ?', [strtolower($validated['platform'])])
            ->first();

        if (! $platform) {
            return ApiResponse::error('Application invalide. Veuillez changer de plateforme.', null, 400);
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

    SessionUser::query()->updateOrCreate(
        ['device_id' => $device->id],
        [
            'user_id' => $user->id,
            'user_agent' => $request->userAgent(),
            'ip_address' => $request->ip(),
            'is_active' => true,
        ]
    );

  // Supprime toute association existante pour ce token (appartenant à un autre device)
    DeviceTokenFcm::query()
        ->where('token', $validated['fcm_token'])
        ->where('device_id', '!=', $device->id)
        ->delete();

    // Puis crée/actualise pour ce device précis
    DeviceTokenFcm::query()->updateOrCreate(
        ['device_id' => $device->id],
        [
            'token' => $validated['fcm_token'],
            'actif' => true,
        ]
    );


        $deviceName = $validated['device_name'] ?? 'api';

    // Access token : courte durée (ex: 24h, votre config actuelle)
        $accessToken = $user->createToken($deviceName . '-access', ['access-api']);
        $accessExpiresAt = Carbon::now()->addDay();

        // Refresh token : longue durée (ex: 30 jours), ability distincte
        $refreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
        $refreshExpiresAt = Carbon::now()->addDays(30);

        return ApiResponse::success('Connexion réussie.', [
            'user' => UserResource::make($user),
            'access_token' => $accessToken->plainTextToken,
            'access_token_expires_at' => $accessExpiresAt?->toIso8601String(),
            'refresh_token' => $refreshToken->plainTextToken,
            'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
            'token_type' => 'Bearer',
        ]);
    }
   public function refreshToken(Request $request): JsonResponse
    {
        $refreshToken = $request->user()->currentAccessToken();

        if (! $request->user()->tokenCan('issue-access-token')) {
            return ApiResponse::error('Token invalide pour cette action.', null, 403);
        }

        // Vérification manuelle de l'expiration du refresh token (30 jours)
        if ($refreshToken->created_at->addDays(30)->isPast()) {
            $refreshToken->delete();
            return ApiResponse::error('Session expirée, veuillez vous reconnecter.', null, 401);
        }

        $user = $request->user();
        $deviceName = str_replace('-refresh', '', $refreshToken->name);

        // Nouvel access token
        $newAccessToken = $user->createToken($deviceName . '-access', ['access-api']);
        $accessExpiresAt = Carbon::now()->addDay();

        // Rotation : on supprime l'ancien refresh token et on en crée un nouveau
        $refreshToken->delete();
        $newRefreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
        $refreshExpiresAt = Carbon::now()->addDays(30);

        return ApiResponse::success('Token actualisé.', [
            'access_token' => $newAccessToken->plainTextToken,
            'access_token_expires_at' => $accessExpiresAt->toIso8601String(),
            'refresh_token' => $newRefreshToken->plainTextToken,
            'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
            'token_type' => 'Bearer',
        ]);
    }

   public function logout(Request $request): JsonResponse
{
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

        $user->update([
            'password' => Hash::make($validated['password']),
        ]);

        $currentToken = $user->currentAccessToken();
        $deviceName = $currentToken instanceof PersonalAccessToken
            ? str_replace(['-access', '-refresh'], '', $currentToken->name)
            : 'api';

        // Supprime TOUS les tokens de l'utilisateur (tous devices confondus)
        $user->tokens()->delete();

        $newAccessToken = $user->createToken($deviceName . '-access', ['access-api']);
        $accessExpiresAt = Carbon::now()->addDay();

        $newRefreshToken = $user->createToken($deviceName . '-refresh', ['issue-access-token']);
        $refreshExpiresAt = Carbon::now()->addDays(30);

        return ApiResponse::success('Mot de passe modifié avec succès.', [
            'access_token' => $newAccessToken->plainTextToken,
            'access_token_expires_at' => $accessExpiresAt->toIso8601String(),
            'refresh_token' => $newRefreshToken->plainTextToken,
            'refresh_token_expires_at' => $refreshExpiresAt->toIso8601String(),
            'token_type' => 'Bearer',
        ]);
    }
}
