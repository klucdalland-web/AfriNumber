<?php

namespace App\Services;

use App\Mail\OtpCodeMail;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Throwable;

class OtpMailService
{
    /**
     * Envoie le code OTP à l'adresse e-mail indiquée.
     *
     * @throws Throwable Si l'envoi échoue
     */
    public function send(string $email, string $otp, int $expiresInMinutes = 10): void
    {
        try {
            Mail::to($email)->send(new OtpCodeMail($otp, $expiresInMinutes));

            Log::info('Code OTP envoyé par e-mail.', [
                'email' => $email,
            ]);
        } catch (Throwable $e) {
            Log::error('Échec de l\'envoi du code OTP par e-mail.', [
                'email' => $email,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
