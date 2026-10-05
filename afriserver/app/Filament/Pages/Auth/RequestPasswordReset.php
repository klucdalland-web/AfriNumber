<?php

namespace App\Filament\Pages\Auth;

use App\Services\AdminPasswordResetService;
use DanHarrin\LivewireRateLimiting\Exceptions\TooManyRequestsException;
use DanHarrin\LivewireRateLimiting\WithRateLimiting;
use Filament\Actions\Action;
use Filament\Auth\Pages\PasswordReset\RequestPasswordReset as BaseRequestPasswordReset;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Schemas\Components\Component;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\HtmlString;
use Illuminate\Validation\ValidationException;

class RequestPasswordReset extends BaseRequestPasswordReset
{
    use WithRateLimiting;

    public function getTitle(): string | Htmlable
    {
        return 'Mot de passe oublié';
    }

    public function getHeading(): string | Htmlable | null
    {
        return 'Réinitialiser le mot de passe';
    }

    public function getSubheading(): string | Htmlable | null
    {
        if (! filament()->hasLogin()) {
            return null;
        }

        return new HtmlString(Blade::render(
            'Entrez votre e-mail administrateur. Un code OTP vous sera envoyé. · <x-filament::link :href="filament()->getLoginUrl()" tabindex="-1">Retour à la connexion</x-filament::link>'
        ));
    }

    protected function getEmailFormComponent(): Component
    {
        return TextInput::make('email')
            ->label('Adresse e-mail')
            ->email()
            ->required()
            ->autocomplete()
            ->autofocus();
    }

    protected function getRequestFormAction(): Action
    {
        return Action::make('request')
            ->label('Envoyer le code OTP')
            ->submit('request');
    }

    public function request(): void
    {
        try {
            $this->rateLimit(5);
        } catch (TooManyRequestsException $exception) {
            $this->getRateLimitedNotification($exception)?->send();

            return;
        }

        $data = $this->form->getState();
        $email = strtolower(trim((string) ($data['email'] ?? '')));

        try {
            $result = app(AdminPasswordResetService::class)->request($email);
        } catch (ValidationException $exception) {
            $message = collect($exception->errors())->flatten()->first()
                ?? 'Impossible d\'envoyer le code pour le moment.';

            Notification::make()
                ->title($message)
                ->danger()
                ->send();

            $this->addError('data.email', $message);

            return;
        }

        Notification::make()
            ->title($result['message'])
            ->success()
            ->send();

        $this->redirect($this->signedResetPasswordUrl($email));
    }

    private function signedResetPasswordUrl(string $email): string
    {
        return URL::temporarySignedRoute(
            'filament.afriNetAdmin.auth.password-reset.reset',
            now()->addMinutes(30),
            [
                'email' => $email,
                'token' => 'otp',
            ],
        );
    }
}
