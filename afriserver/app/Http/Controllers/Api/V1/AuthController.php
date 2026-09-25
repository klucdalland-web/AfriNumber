<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Auth\ChangePasswordRequest;
use App\Http\Requests\Api\V1\Auth\ForgotPasswordRequest;
use App\Http\Requests\Api\V1\Auth\LoginRequest;
use App\Http\Requests\Api\V1\Auth\RegisterRequest;
use App\Http\Requests\Api\V1\Auth\ResendOtpRequest;
use App\Http\Requests\Api\V1\Auth\ResetPasswordRequest;
use App\Http\Requests\Api\V1\Auth\VerifyOtpRequest;
use App\Http\Resources\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\OtpVerification;
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
        $email = $validated['email'] ?? null;
        $phoneNumber = $validated['phone_number'] ?? null;

        $pays = Pays::query()->where('id', $validated['contrie_id'])->first();

        if (! $pays || ! $pays->organisation_id) {
            throw ValidationException::withMessages([
                'contrie_id' => ['Le pays sélectionné est invalide.'],
            ]);
        }

        if (User::query()->where('email', $validated['email'])->exists()) {
            throw ValidationException::withMessages([
                'email' => ['Cette adresse email est déjà utilisée.'],
            ]);
        }

        if (User::query()->where('phone_number', $validated['phone_number'])->exists()) {
            throw ValidationException::withMessages([
                'phone_number' => ['Ce numéro de téléphone est déjà utilisé.'],
            ]);
        }

        $typeUserId = TypeUser::query()->where('code', 'user')->value('id');

        $payload = array_merge($validated, [
            'password' => Hash::make($validated['password']),
            'type_user_id' => $typeUserId,
            'organisation_id' => $pays->organisation_id,
        ]);

        $send = $this->sendOtpOrThrottle($email, $phoneNumber, 'register', $payload);

        if ($send instanceof JsonResponse) {
            return $send;
        }

        return ApiResponse::success(
            'Un code de vérification a été envoyé. Veuillez le saisir pour finaliser votre inscription.',
            $this->otpResendMeta($send['resend_count'])
        );
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

        if ($user && $user->locked_until && $user->locked_until->isFuture()) {
            $minutesLeft = (int) ceil(now()->diffInMinutes($user->locked_until));

            $timeMessage = $minutesLeft >= 60
                ? (int) ceil($minutesLeft / 60) . ' heure(s)'
                : $minutesLeft . ' minute(s)';

            return ApiResponse::error(
                "Compte temporairement verrouillé suite à plusieurs tentatives échouées. Réessayez dans {$timeMessage}, ou réinitialisez votre mot de passe.",
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

        if ($user->failed_login_attempts > 0 || $user->locked_until) {
            $user->update([
                'failed_login_attempts' => 0,
                'locked_until' => null,
            ]);
        }

        if ($user->statut !== 'actif') {
            return ApiResponse::error('Compte non actif.', null, 403);
        }

        $payload = array_merge($validated, ['user_id' => $user->id]);
        unset($payload['password']);

        $send = $this->sendOtpOrThrottle($user->email, $user->phone_number, 'login', $payload);

        if ($send instanceof JsonResponse) {
            return $send;
        }

        return ApiResponse::success(
            'Un code de vérification a été envoyé. Veuillez le saisir pour finaliser la connexion.',
            $this->otpResendMeta($send['resend_count'])
        );
    }

    public function verifyOtp(VerifyOtpRequest $request): JsonResponse
    {
        $validated = $request->validated();

        $otp = $this->findOtp(
            $validated['email'] ?? null,
            $validated['phone_number'] ?? null,
            $validated['purpose']
        );

        if (! $otp) {
            throw ValidationException::withMessages([
                'code' => ['Code invalide ou expiré. Veuillez recommencer.'],
            ]);
        }

        // Vérifie si bloqué suite à trop de tentatives
        if ($otp->locked_until && $otp->locked_until->isFuture()) {
            $minutesLeft = max(1, (int) ceil(now()->diffInMinutes($otp->locked_until)));

            return ApiResponse::error(
                "Trop de tentatives échouées. Veuillez réessayer dans {$minutesLeft} minute(s).",
                [
                    'locked_minutes_left' => $minutesLeft,
                    'locked_until' => $otp->locked_until->toIso8601String(),
                ],
                423
            );
        }

        // Lock expiré → on remet les tentatives à zéro
        if ($otp->attempts > 0 && $otp->locked_until && $otp->locked_until->isPast()) {
            $otp->update([
                'attempts' => 0,
                'locked_until' => null,
            ]);
            $otp->refresh();
        }

        if ($otp->expires_at->isPast()) {
            throw ValidationException::withMessages([
                'code' => ['Ce code a expiré. Utilisez resend-otp pour en recevoir un nouveau.'],
            ]);
        }

        if (! Hash::check($validated['code'], $otp->code)) {
            $otp->increment('attempts');

            if ($otp->attempts >= 5) {
                $otp->update(['locked_until' => now()->addMinutes(5)]);

                return ApiResponse::error(
                    'Trop de tentatives échouées. Veuillez réessayer dans 5 minute(s).',
                    ['locked_minutes_left' => 5],
                    423
                );
            }

            $remaining = max(0, 5 - $otp->attempts);

            throw ValidationException::withMessages([
                'code' => ["Code incorrect. Il vous reste {$remaining} tentative(s)."],
            ]);
        }

        $payload = $otp->payload;

        try {
            $result = DB::transaction(function () use ($payload, $request, $validated) {
                if ($validated['purpose'] === 'register') {
                    
                    if (User::query()->where('email', $payload['email'])->exists()) {
                        throw ValidationException::withMessages([
                            'email' => ['Cette adresse email est déjà utilisée.'],
                        ]);
                    }

                    if (User::query()->where('phone_number', $payload['phone_number'])->exists()) {
                        throw ValidationException::withMessages([
                            'phone_number' => ['Ce numéro de téléphone est déjà utilisé.'],
                        ]);
                    }

                    $user = User::query()->create([
                        'name' => $payload['name'],
                        'email' => $payload['email'],
                        'first_name' => $payload['first_name'],
                        'phone_number' => $payload['phone_number'],
                        'password' => $payload['password'], // déjà haché
                        'type_user_id' => $payload['type_user_id'],
                        'statut' => 'actif',
                        'status_valide' => 'non_valide',
                        'organisation_id' => $payload['organisation_id'],
                    ]);

                } else {
                    $user = User::query()->findOrFail($payload['user_id']);
                }

                $user->load(['typeUser', 'organisation']);

                $tokens = $this->registerDeviceAndTokens($user, $payload, $request);

                return array_merge(['user' => UserResource::make($user)], $tokens);
            });

            $otp->delete();

            $message = $validated['purpose'] === 'register' ? 'Inscription réussie.' : 'Connexion réussie.';
            $status = $validated['purpose'] === 'register' ? 201 : 200;

            return ApiResponse::success($message, $result, $status);
        } catch (ValidationException $e) {
            throw $e;
        } catch (Throwable $e) {
            Log::error('Erreur lors de la vérification OTP.', [
                'message' => $e->getMessage(),
                'purpose' => $validated['purpose'],
            ]);

            return ApiResponse::error('Une erreur est survenue.', null, 500);
        }
    }

    /**
     * Renvoie un nouveau code OTP en réutilisant le payload déjà stocké
     * (pas besoin de renvoyer password / device / etc.).
     */
    public function resendOtp(ResendOtpRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $email = $validated['email'] ?? null;
        $phoneNumber = $validated['phone_number'] ?? null;
        $purpose = $validated['purpose'];

        $otp = $this->findOtp($email, $phoneNumber, $purpose);

        if (! $otp) {
            throw ValidationException::withMessages([
                'code' => ['Aucune demande en cours. Veuillez recommencer la connexion ou l\'inscription.'],
            ]);
        }

        $send = $this->sendOtpOrThrottle(
            $otp->email,
            $otp->phone_number,
            $purpose,
            $otp->payload ?? []
        );

        if ($send instanceof JsonResponse) {
            return $send;
        }

        return ApiResponse::success(
            'Un nouveau code de vérification a été envoyé.',
            $this->otpResendMeta($send['resend_count'])
        );
    }

    /**
     * Envoie un OTP en respectant :
     * - lock codes erronés (locked_until)
     * - compteur d'envois progressif (login / register / resend partagent le même compteur)
     * - à partir du délai de 5 min → email/téléphone considérés comme bloqués
     *
     * @return array{resend_count: int}|JsonResponse
     */
    private function sendOtpOrThrottle(
        ?string $email,
        ?string $phoneNumber,
        string $purpose,
        array $payload
    ): array|JsonResponse {
        $existing = $this->findOtp($email, $phoneNumber, $purpose);

        if ($existing && $existing->locked_until && $existing->locked_until->isFuture()) {
            return $this->otpLockResponse($email, $phoneNumber, $purpose)
                ?? ApiResponse::error('Trop de tentatives échouées.', null, 423);
        }

        if ($existing) {
            $throttle = $this->otpSendThrottleResponse($existing, $purpose);

            if ($throttle) {
                return $throttle;
            }
        }

        $isSubsequentSend = $existing !== null;
        $resendCount = $this->issueOtp(
            email: $existing?->email ?? $email,
            phoneNumber: $existing?->phone_number ?? $phoneNumber,
            purpose: $purpose,
            payload: $payload,
            isResend: $isSubsequentSend
        );

        return ['resend_count' => $resendCount];
    }

    /**
     * Si le cooldown d'envoi n'est pas écoulé → bloque email/téléphone.
     * À partir de 5 min d'attente → message de blocage (423).
     */
    private function otpSendThrottleResponse(OtpVerification $otp, string $purpose): ?JsonResponse
    {
        $requiredWaitMinutes = $this->resendCooldownMinutes((int) $otp->resend_count);
        $availableAt = $otp->updated_at?->copy()->addMinutes($requiredWaitMinutes);

        if (! $availableAt || ! $availableAt->isFuture()) {
            return null;
        }

        $secondsLeft = max(1, (int) now()->diffInSeconds($availableAt));
        $minutesLeft = max(1, (int) ceil($secondsLeft / 60));
        $action = $purpose === 'register' ? 'inscription' : 'connexion';

        $payload = [
            'retry_after_seconds' => $secondsLeft,
            'retry_after_minutes' => $minutesLeft,
            'required_wait_minutes' => $requiredWaitMinutes,
            'resend_count' => (int) $otp->resend_count,
            'next_resend_at' => $availableAt->toIso8601String(),
            'purpose' => $purpose,
        ];

        // Délai >= 5 min → email / numéro bloqués
        if ($requiredWaitMinutes >= 5) {
            return ApiResponse::error(
                "Trop de codes envoyés. {$action} impossible avec cet email ou ce numéro pendant encore {$minutesLeft} minute(s).",
                array_merge($payload, [
                    'locked_minutes_left' => $minutesLeft,
                    'locked_until' => $availableAt->toIso8601String(),
                ]),
                423
            );
        }

        return ApiResponse::error(
            "Veuillez patienter {$minutesLeft} minute(s) avant de renvoyer un code.",
            $payload,
            429
        );
    }

    /**
     * Métadonnées pour le timer "renvoyer le code" côté client.
     *
     * @return array{resend_count: int, next_resend_wait_minutes: int, next_resend_at: string}
     */
    private function otpResendMeta(int $resendCount): array
    {
        $nextWaitMinutes = $this->resendCooldownMinutes($resendCount);

        return [
            'resend_count' => $resendCount,
            'next_resend_wait_minutes' => $nextWaitMinutes,
            'next_resend_at' => now()->addMinutes($nextWaitMinutes)->toIso8601String(),
        ];
    }

    /**
     * Recherche un OTP par email et/ou téléphone + purpose.
     * Si les deux sont fournis → match si email OU téléphone correspond
     * (évite de contourner un lock en changeant d'identifiant).
     */
    private function findOtp(?string $email, ?string $phoneNumber, string $purpose): ?OtpVerification
    {
        return OtpVerification::query()
            ->where('purpose', $purpose)
            ->where(function ($query) use ($email, $phoneNumber): void {
                if ($email) {
                    $query->where('email', $email);
                }

                if ($phoneNumber) {
                    $email
                        ? $query->orWhere('phone_number', $phoneNumber)
                        : $query->where('phone_number', $phoneNumber);
                }
            })
            ->latest()
            ->first();
    }

    /**
     * Bloque login / register / resend tant que l'OTP est verrouillé
     * pour cet email OU ce numéro.
     */
    private function otpLockResponse(?string $email, ?string $phoneNumber, string $purpose): ?JsonResponse
    {
        $otp = $this->findOtp($email, $phoneNumber, $purpose);

        if (! $otp || ! $otp->locked_until || ! $otp->locked_until->isFuture()) {
            return null;
        }

        $minutesLeft = max(1, (int) ceil(now()->diffInMinutes($otp->locked_until)));
        $action = $purpose === 'register' ? 'inscription' : 'connexion';

        return ApiResponse::error(
            "Trop de tentatives échouées sur le code OTP. {$action} impossible avec cet email ou ce numéro pendant encore {$minutesLeft} minute(s).",
            [
                'locked_minutes_left' => $minutesLeft,
                'locked_until' => $otp->locked_until->toIso8601String(),
                'purpose' => $purpose,
            ],
            423
        );
    }

    /**
     * Délai d'attente progressif avant chaque nouvel envoi (en minutes).
     * 2e envoi → 1 min, 3e → 5 min, puis 10, 15, 30, 60 (plafond).
     */
    private function resendCooldownMinutes(int $resendCount): int
    {
        $delays = [1, 5, 10, 15, 30, 60];

        return $delays[min($resendCount, count($delays) - 1)];
    }

    /**
     * Génère, stocke et envoie un code OTP.
     * Une seule ligne par (email/téléphone, purpose) — mise à jour à chaque nouvelle demande.
     *
     * @return int Nouveau resend_count
     */
    private function issueOtp(
        ?string $email,
        ?string $phoneNumber,
        string $purpose,
        array $payload,
        bool $isResend = false
    ): int {
        $code = (string) random_int(100000, 999999);
        $code = 123456; // Pour tests, à retirer en production

        $resendCount = 0;

        if ($isResend) {
            $existing = $this->findOtp($email, $phoneNumber, $purpose);
            $resendCount = (int) ($existing?->resend_count ?? 0) + 1;
        }

        OtpVerification::query()->updateOrCreate(
            [
                'email' => $email,
                'phone_number' => $phoneNumber,
                'purpose' => $purpose,
            ],
            [
                'code' => Hash::make($code),
                'payload' => $payload,
                'attempts' => 0,
                'resend_count' => $resendCount,
                // Ne pas effacer un lock codes-erronés ici si encore actif — géré en amont.
                // Pour un envoi autorisé, on repart sur un code neuf.
                'locked_until' => null,
                'expires_at' => now()->addMinutes(10),
            ]
        );

        // TODO : envoyer $code par email ou SMS
        Log::info('Code OTP généré.', [
            'email' => $email,
            'phone_number' => $phoneNumber,
            'purpose' => $purpose,
            'resend_count' => $resendCount,
        ]);

        return $resendCount;
    }

    /**
     * Incrémente le compteur d'échecs et verrouille le compte selon un seuil progressif.
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

    public function forgotPassword(ForgotPasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $email = $validated['email'] ?? null;
        $phoneNumber = $validated['phone_number'] ?? null;

        $genericMessage = 'Si ce compte existe, un code de réinitialisation a été envoyé.';

        $user = $this->findUserByEmailOrPhone($email, $phoneNumber);

        // Compte inconnu : même forme de réponse (anti-énumération)
        if (! $user) {
            return ApiResponse::success($genericMessage, $this->otpResendMeta(0));
        }

        $send = $this->sendPasswordResetOrThrottle($user->email, $user->phone_number);

        if ($send instanceof JsonResponse) {
            return $send;
        }

        return ApiResponse::success($genericMessage, $this->otpResendMeta($send['resend_count']));
    }

    public function resetPassword(ResetPasswordRequest $request): JsonResponse
    {
        $validated = $request->validated();
        $email = $validated['email'] ?? null;
        $phoneNumber = $validated['phone_number'] ?? null;

        $resetCode = $this->findPasswordResetCode($email, $phoneNumber);

        if (! $resetCode) {
            throw ValidationException::withMessages([
                'code' => ['Code invalide ou expiré. Veuillez recommencer.'],
            ]);
        }

        if ($resetCode->locked_until && $resetCode->locked_until->isFuture()) {
            $minutesLeft = max(1, (int) ceil(now()->diffInMinutes($resetCode->locked_until)));

            return ApiResponse::error(
                "Trop de tentatives échouées. Réinitialisation impossible avec cet email ou ce numéro pendant encore {$minutesLeft} minute(s).",
                [
                    'locked_minutes_left' => $minutesLeft,
                    'locked_until' => $resetCode->locked_until->toIso8601String(),
                ],
                423
            );
        }

        // Lock expiré → reset des tentatives
        if ($resetCode->attempts > 0 && $resetCode->locked_until && $resetCode->locked_until->isPast()) {
            $resetCode->update([
                'attempts' => 0,
                'locked_until' => null,
            ]);
            $resetCode->refresh();
        }

        if ($resetCode->expires_at->isPast()) {
            throw ValidationException::withMessages([
                'code' => ['Ce code a expiré. Utilisez forgot-password pour en recevoir un nouveau.'],
            ]);
        }

        if (! Hash::check($validated['code'], $resetCode->code)) {
            $resetCode->increment('attempts');

            if ($resetCode->attempts >= 5) {
                $resetCode->update(['locked_until' => now()->addMinutes(5)]);

                return ApiResponse::error(
                    'Trop de tentatives échouées. Veuillez réessayer dans 5 minute(s).',
                    ['locked_minutes_left' => 5],
                    423
                );
            }

            $remaining = max(0, 5 - $resetCode->attempts);

            throw ValidationException::withMessages([
                'code' => ["Code incorrect. Il vous reste {$remaining} tentative(s)."],
            ]);
        }

        $user = $this->findUserByEmailOrPhone(
            $resetCode->email ?? $email,
            $resetCode->phone_number ?? $phoneNumber
        );

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

    /**
     * Envoie un code reset password avec la même logique anti-spam que l'OTP.
     *
     * @return array{resend_count: int}|JsonResponse
     */
    private function sendPasswordResetOrThrottle(?string $email, ?string $phoneNumber): array|JsonResponse
    {
        $existing = $this->findPasswordResetCode($email, $phoneNumber);

        if ($existing && $existing->locked_until && $existing->locked_until->isFuture()) {
            $minutesLeft = max(1, (int) ceil(now()->diffInMinutes($existing->locked_until)));

            return ApiResponse::error(
                "Trop de tentatives échouées. Réinitialisation impossible avec cet email ou ce numéro pendant encore {$minutesLeft} minute(s).",
                [
                    'locked_minutes_left' => $minutesLeft,
                    'locked_until' => $existing->locked_until->toIso8601String(),
                ],
                423
            );
        }

        if ($existing) {
            $throttle = $this->passwordResetSendThrottleResponse($existing);

            if ($throttle) {
                return $throttle;
            }
        }

        $resendCount = $this->issuePasswordResetCode(
            email: $existing?->email ?? $email,
            phoneNumber: $existing?->phone_number ?? $phoneNumber,
            isResend: $existing !== null
        );

        return ['resend_count' => $resendCount];
    }

    private function passwordResetSendThrottleResponse(PasswordResetCode $reset): ?JsonResponse
    {
        $requiredWaitMinutes = $this->resendCooldownMinutes((int) $reset->resend_count);
        $availableAt = $reset->updated_at?->copy()->addMinutes($requiredWaitMinutes);

        if (! $availableAt || ! $availableAt->isFuture()) {
            return null;
        }

        $secondsLeft = max(1, (int) now()->diffInSeconds($availableAt));
        $minutesLeft = max(1, (int) ceil($secondsLeft / 60));

        $payload = [
            'retry_after_seconds' => $secondsLeft,
            'retry_after_minutes' => $minutesLeft,
            'required_wait_minutes' => $requiredWaitMinutes,
            'resend_count' => (int) $reset->resend_count,
            'next_resend_at' => $availableAt->toIso8601String(),
        ];

        if ($requiredWaitMinutes >= 5) {
            return ApiResponse::error(
                "Trop de codes envoyés. Réinitialisation impossible avec cet email ou ce numéro pendant encore {$minutesLeft} minute(s).",
                array_merge($payload, [
                    'locked_minutes_left' => $minutesLeft,
                    'locked_until' => $availableAt->toIso8601String(),
                ]),
                423
            );
        }

        return ApiResponse::error(
            "Veuillez patienter {$minutesLeft} minute(s) avant de renvoyer un code.",
            $payload,
            429
        );
    }

    private function findPasswordResetCode(?string $email, ?string $phoneNumber): ?PasswordResetCode
    {
        if (! $email && ! $phoneNumber) {
            return null;
        }

        return PasswordResetCode::query()
            ->where(function ($query) use ($email, $phoneNumber): void {
                if ($email) {
                    $query->where('email', $email);
                }

                if ($phoneNumber) {
                    $email
                        ? $query->orWhere('phone_number', $phoneNumber)
                        : $query->where('phone_number', $phoneNumber);
                }
            })
            ->latest()
            ->first();
    }

    private function findUserByEmailOrPhone(?string $email, ?string $phoneNumber): ?User
    {
        if (! $email && ! $phoneNumber) {
            return null;
        }

        return User::query()
            ->where(function ($query) use ($email, $phoneNumber): void {
                if ($email) {
                    $query->where('email', $email);
                }

                if ($phoneNumber) {
                    $email
                        ? $query->orWhere('phone_number', $phoneNumber)
                        : $query->where('phone_number', $phoneNumber);
                }
            })
            ->first();
    }

    /**
     * @return int Nouveau resend_count
     */
    private function issuePasswordResetCode(
        ?string $email,
        ?string $phoneNumber,
        bool $isResend = false
    ): int {
        $code = (string) random_int(100000, 999999);
        $code = 123456; // Pour tests, à retirer en production

        $resendCount = 0;

        if ($isResend) {
            $existing = $this->findPasswordResetCode($email, $phoneNumber);
            $resendCount = (int) ($existing?->resend_count ?? 0) + 1;
        }

        PasswordResetCode::query()->updateOrCreate(
            [
                'email' => $email,
                'phone_number' => $phoneNumber,
            ],
            [
                'code' => Hash::make($code),
                'attempts' => 0,
                'resend_count' => $resendCount,
                'locked_until' => null,
                'expires_at' => now()->addMinutes(15),
            ]
        );

        // TODO : envoyer $code par email ou SMS
        Log::info('Code de réinitialisation généré.', [
            'email' => $email,
            'phone_number' => $phoneNumber,
            'resend_count' => $resendCount,
        ]);

        return $resendCount;
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
}