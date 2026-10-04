<?php

namespace App\Services;

use App\Mail\OtpCodeMail;
use App\Models\Pays;
use App\Models\User;
use App\Support\Brand;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

class OtpMailService
{
    /**
     * Envoie le code OTP à l'adresse e-mail indiquée via l'API SMTP.
     * Les dates affichées utilisent le fuseau du pays du destinataire.
     *
     * @throws Throwable Si l'envoi échoue
     */
    public function send(
        string $email,
        string $otp,
        int $expiresInMinutes = 10,
        ?User $user = null,
        ?Pays $pays = null,
        ?string $countryCode = null,
        ?int $paysId = null,
    ): void {
        $secret = config('services.mail_api.secret');
        $url = config('services.mail_api.url');

        if (blank($secret) || blank($url)) {
            throw new RuntimeException('La configuration MAIL_API_SECRET / MAIL_API_URL est manquante.');
        }

        $resolvedUser = $user ?? User::query()->with('pays')->where('email', $email)->first();

        $mailable = new OtpCodeMail(
            otp: $otp,
            expiresInMinutes: $expiresInMinutes,
            user: $resolvedUser,
            pays: $pays,
            countryCode: $countryCode,
            paysId: $paysId ?? $resolvedUser?->pays_id,
        );
        $html = $mailable->render();
        $appName = Brand::name();
        $text = "Votre code de vérification {$appName} : {$otp}. "
            ."Expire le {$mailable->expiresAtLabel}. "
            ."Valable {$expiresInMinutes} minutes.";

        try {
            Http::withHeaders([
                'x-api-secret' => $secret,
                'Content-Type' => 'application/json',
            ])
                ->connectTimeout(3)
                ->timeout(15)
                ->post($url, [
                    'to' => $email,
                    'subject' => $mailable->envelope()->subject,
                    'html' => $html,
                    'text' => $text,
                ])
                ->throw();

            Log::info('Code OTP envoyé par e-mail.', [
                'email' => $email,
                'timezone' => $mailable->recipientTimezone,
            ]);
        } catch (RequestException $e) {
            Log::error('Échec de l\'envoi du code OTP par e-mail.', [
                'email' => $email,
                'status' => $e->response?->status(),
                'error' => $e->getMessage(),
            ]);

            throw $e;
        } catch (Throwable $e) {
            Log::error('Échec de l\'envoi du code OTP par e-mail.', [
                'email' => $email,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
