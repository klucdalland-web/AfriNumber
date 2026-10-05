<?php

namespace App\Services;

use App\Mail\CampaignMessageMail;
use App\Models\User;
use Illuminate\Http\Client\RequestException;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use RuntimeException;
use Throwable;

class CampaignMailService
{
    /**
     * @throws Throwable
     */
    public function send(User $user, string $subject, string $title, string $body): void
    {
        $secret = config('services.mail_api.secret');
        $url = config('services.mail_api.url');

        if (blank($secret) || blank($url)) {
            throw new RuntimeException('La configuration MAIL_API_SECRET / MAIL_API_URL est manquante.');
        }

        if (blank($user->email)) {
            throw new RuntimeException('Utilisateur sans adresse e-mail.');
        }

        $mailable = new CampaignMessageMail($user, $subject, $title, $body);
        $html = $mailable->render();
        $text = "{$title}\n\n{$body}";

        try {
            Http::withHeaders([
                'x-api-secret' => $secret,
                'Content-Type' => 'application/json',
            ])
                ->connectTimeout(3)
                ->timeout(15)
                ->post($url, [
                    'to' => $user->email,
                    'subject' => $subject,
                    'html' => $html,
                    'text' => $text,
                ])
                ->throw();
        } catch (RequestException $e) {
            Log::error('Échec envoi mail campagne', [
                'user_id' => $user->id,
                'email' => $user->email,
                'status' => $e->response?->status(),
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }
    }
}
