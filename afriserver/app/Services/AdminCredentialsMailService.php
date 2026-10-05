<?php

namespace App\Services;

use App\Mail\AdminCredentialsMail;
use App\Models\User;
use App\Support\Brand;
use Filament\Facades\Filament;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

class AdminCredentialsMailService
{
    /**
     * Envoie les identifiants admin à l'adresse e-mail indiquée via l'API SMTP.
     *
     * @throws Throwable Si l'envoi échoue
     */
    public function send(User $user, string $plainPassword): void
    {
        $secret = config('services.mail_api.secret');
        $url = config('services.mail_api.url');

        if (blank($secret) || blank($url)) {
            throw new RuntimeException('La configuration MAIL_API_SECRET / MAIL_API_URL est manquante.');
        }

        $loginUrl = url(Filament::getPanel('afriNetAdmin')->getLoginUrl());
        $user->loadMissing('pays');
        $mailable = new AdminCredentialsMail($user, $plainPassword, $loginUrl);
        $html = $mailable->render();
        $appName = Brand::name();
        $text = "Bonjour {$user->first_name},\n\n"
            ."Votre compte {$appName} est prêt.\n"
            ."Adresse e-mail : {$user->email}\n"
            ."Mot de passe provisoire : {$plainPassword}\n"
            ."Connexion : {$loginUrl}\n\n"
            .'Merci de modifier ce mot de passe dès votre première connexion.';

        try {
            Http::withHeaders([
                'x-api-secret' => $secret,
                'Content-Type' => 'application/json',
            ])
                ->connectTimeout(3)
                ->timeout(15)
                ->post($url, [
                    'to' => $user->email,
                    'subject' => $mailable->envelope()->subject,
                    'html' => $html,
                    'text' => $text,
                ])
                ->throw();

            Log::info('Identifiants admin envoyés par e-mail.', [
                'email' => $user->email,
                'user_id' => $user->id,
            ]);
        } catch (RequestException $e) {
            Log::error('Échec de l\'envoi des identifiants admin par e-mail.', [
                'email' => $user->email,
                'user_id' => $user->id,
                'status' => $e->response?->status(),
                'error' => $e->getMessage(),
            ]);

            throw $e;
        } catch (Throwable $e) {
            Log::error('Échec de l\'envoi des identifiants admin par e-mail.', [
                'email' => $user->email,
                'user_id' => $user->id,
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}