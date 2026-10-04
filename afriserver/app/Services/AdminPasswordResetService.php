<?php

namespace App\Services;

use App\Models\PasswordResetCode;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use RuntimeException;
use Throwable;

class AdminPasswordResetService
{
    public const GENERIC_REQUEST_MESSAGE = 'Si ce compte administrateur existe, un code de réinitialisation a été envoyé.';

    public const SUCCESS_RESET_MESSAGE = 'Mot de passe réinitialisé avec succès. Vous pouvez maintenant vous reconnecter.';

    /**
     * Demande un code OTP pour un admin du panel. Toujours le même message (anti-énumération).
     *
     * @return array{message: string, sent: bool, resend_count: int}
     *
     * @throws ValidationException
     */
    public function request(string $email): array
    {
        $email = strtolower(trim($email));
        $user = $this->findAdminByEmail($email);

        if (! $user) {
            return [
                'message' => self::GENERIC_REQUEST_MESSAGE,
                'sent' => false,
                'resend_count' => 0,
            ];
        }

        $resendCount = $this->sendOrThrottle($user->email, $user->phone_number);

        return [
            'message' => self::GENERIC_REQUEST_MESSAGE,
            'sent' => true,
            'resend_count' => $resendCount,
        ];
    }

    /**
     * Renvoie un code OTP (même règles de throttle).
     *
     * @return array{message: string, sent: bool, resend_count: int}
     *
     * @throws ValidationException
     */
    public function resend(string $email): array
    {
        return $this->request($email);
    }

    /**
     * Vérifie l'OTP et met à jour le mot de passe admin.
     *
     * @throws ValidationException
     */
    public function reset(string $email, string $code, string $password): void
    {
        $email = strtolower(trim($email));
        $resetCode = $this->findPasswordResetCode($email);

        if (! $resetCode) {
            throw ValidationException::withMessages([
                'data.code' => 'Code invalide ou expiré. Veuillez recommencer.',
            ]);
        }

        if ($resetCode->locked_until && $resetCode->locked_until->isFuture()) {
            $minutesLeft = max(1, (int) ceil(now()->diffInMinutes($resetCode->locked_until)));

            throw ValidationException::withMessages([
                'data.code' => "Trop de tentatives échouées. Réessayez dans {$minutesLeft} minute(s).",
            ]);
        }

        if ($resetCode->attempts > 0 && $resetCode->locked_until && $resetCode->locked_until->isPast()) {
            $resetCode->update([
                'attempts' => 0,
                'locked_until' => null,
            ]);
            $resetCode->refresh();
        }

        if ($resetCode->expires_at->isPast()) {
            throw ValidationException::withMessages([
                'data.code' => 'Ce code a expiré. Demandez-en un nouveau.',
            ]);
        }

        if (! Hash::check($code, $resetCode->code)) {
            $resetCode->increment('attempts');

            if ($resetCode->attempts >= 5) {
                $resetCode->update(['locked_until' => now()->addMinutes(5)]);

                throw ValidationException::withMessages([
                    'data.code' => 'Trop de tentatives échouées. Veuillez réessayer dans 5 minute(s).',
                ]);
            }

            $remaining = max(0, 5 - $resetCode->attempts);

            throw ValidationException::withMessages([
                'data.code' => "Code incorrect. Il vous reste {$remaining} tentative(s).",
            ]);
        }

        $user = $this->findAdminByEmail($resetCode->email ?? $email);

        if (! $user) {
            throw ValidationException::withMessages([
                'data.email' => 'Compte administrateur introuvable.',
            ]);
        }

        try {
            DB::transaction(function () use ($user, $password, $resetCode): void {
                $user->update([
                    'password' => Hash::make($password),
                    'failed_login_attempts' => 0,
                    'locked_until' => null,
                ]);

                $user->tokens()->delete();
                $resetCode->delete();
            });

            app(ObservabilityService::class)->action(
                category: 'security',
                action: 'admin.password_reset',
                message: 'Mot de passe admin réinitialisé via OTP',
                dataAfter: [
                    'password_reset' => true,
                    'via' => 'afriNetAdmin',
                ],
                user: $user,
            );
        } catch (ValidationException $e) {
            throw $e;
        } catch (Throwable $e) {
            Log::error('Erreur lors de la réinitialisation du mot de passe admin.', [
                'email' => $email,
                'error' => $e->getMessage(),
            ]);

            throw new RuntimeException('Une erreur est survenue lors de la réinitialisation.');
        }
    }

    private function findAdminByEmail(string $email): ?User
    {
        $user = User::query()
            ->with('typeUser')
            ->where('email', $email)
            ->first();

        if (! $user || ! $user->isAdminType()) {
            return null;
        }

        return $user;
    }

    /**
     * @throws ValidationException
     */
    private function sendOrThrottle(?string $email, ?string $phoneNumber): int
    {
        $existing = $this->findPasswordResetCode($email, $phoneNumber);

        if ($existing && $existing->locked_until && $existing->locked_until->isFuture()) {
            $minutesLeft = max(1, (int) ceil(now()->diffInMinutes($existing->locked_until)));

            throw ValidationException::withMessages([
                'data.email' => "Trop de tentatives échouées. Réessayez dans {$minutesLeft} minute(s).",
            ]);
        }

        if ($existing) {
            $this->assertSendAllowed($existing);
        }

        return $this->issueCode(
            email: $existing?->email ?? $email,
            phoneNumber: $existing?->phone_number ?? $phoneNumber,
            isResend: $existing !== null,
        );
    }

    /**
     * @throws ValidationException
     */
    private function assertSendAllowed(PasswordResetCode $reset): void
    {
        $requiredWaitMinutes = $this->resendCooldownMinutes((int) $reset->resend_count);
        $availableAt = $reset->updated_at?->copy()->addMinutes($requiredWaitMinutes);

        if (! $availableAt || ! $availableAt->isFuture()) {
            return;
        }

        $minutesLeft = max(1, (int) ceil(now()->diffInSeconds($availableAt) / 60));

        throw ValidationException::withMessages([
            'data.email' => "Veuillez patienter {$minutesLeft} minute(s) avant de renvoyer un code.",
        ]);
    }

    private function findPasswordResetCode(?string $email, ?string $phoneNumber = null): ?PasswordResetCode
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

    private function issueCode(?string $email, ?string $phoneNumber, bool $isResend = false): int
    {
        $code = (string) random_int(100000, 999999);
        $resendCount = 0;

        if ($isResend) {
            $existing = $this->findPasswordResetCode($email, $phoneNumber);
            $resendCount = (int) ($existing?->resend_count ?? 0) + 1;
        }

        $reset = PasswordResetCode::query()->updateOrCreate(
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

        if (! $email) {
            $reset->delete();

            throw ValidationException::withMessages([
                'data.email' => 'Impossible d\'envoyer le code : adresse e-mail manquante.',
            ]);
        }

        try {
            $recipientUser = User::query()
                ->with('pays')
                ->where('email', $email)
                ->first();

            app(OtpMailService::class)->send(
                email: $email,
                otp: $code,
                expiresInMinutes: 15,
                user: $recipientUser,
                paysId: $recipientUser?->pays_id,
            );
        } catch (Throwable $e) {
            $reset->delete();

            Log::error('Envoi e-mail reset admin échoué.', [
                'email' => $email,
                'error' => $e->getMessage(),
            ]);

            throw ValidationException::withMessages([
                'data.email' => 'Impossible d\'envoyer le code OTP. Vérifiez le service mail (MAIL_API_URL) puis réessayez.',
            ]);
        }

        Log::info('Code de réinitialisation admin généré.', [
            'email' => $email,
            'resend_count' => $resendCount,
        ]);

        return $resendCount;
    }

    private function resendCooldownMinutes(int $resendCount): int
    {
        $delays = [1, 5, 10, 15, 30, 60];

        return $delays[min($resendCount, count($delays) - 1)];
    }
}
