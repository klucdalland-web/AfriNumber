<?php

namespace App\Filament\Pages\Auth;

use App\Services\AdminPasswordResetService;
use DanHarrin\LivewireRateLimiting\Exceptions\TooManyRequestsException;
use DanHarrin\LivewireRateLimiting\WithRateLimiting;
use Filament\Actions\Action;
use Filament\Auth\Http\Responses\Contracts\PasswordResetResponse;
use Filament\Auth\Pages\PasswordReset\ResetPassword as BaseResetPassword;
use Filament\Facades\Filament;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Schemas\Components\Component;
use Filament\Schemas\Schema;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Support\Facades\Blade;
use Illuminate\Support\HtmlString;
use Illuminate\Validation\Rules\Password as PasswordRule;
use Illuminate\Validation\ValidationException;
use Livewire\Attributes\Locked;
use RuntimeException;

class ResetPassword extends BaseResetPassword
{
    use WithRateLimiting;

    #[Locked]
    public ?string $email = null;

    /**
     * Inutilisé (flux OTP) — conservé pour compatibilité avec la page Filament de base.
     */
    #[Locked]
    public ?string $token = null;

    /**
     * @var array<string, mixed> | null
     */
    public ?array $data = [];

    public function mount(?string $email = null, ?string $token = null): void
    {
        if (Filament::auth()->check()) {
            redirect()->intended(Filament::getUrl());
        }

        $this->email = $email ?? request()->query('email');
        $this->token = null;

        $this->form->fill([
            'email' => $this->email,
        ]);
    }

    public function defaultForm(Schema $schema): Schema
    {
        return $schema
            ->statePath('data');
    }

    public function getTitle(): string | Htmlable
    {
        return 'Nouveau mot de passe';
    }

    public function getHeading(): string | Htmlable | null
    {
        return 'Entrez le code OTP';
    }

    public function getSubheading(): string | Htmlable | null
    {
        return new HtmlString(Blade::render(
            'Saisissez le code reçu par e-mail, puis choisissez un nouveau mot de passe. · <x-filament::link :href="filament()->getRequestPasswordResetUrl()" tabindex="-1">Renvoyer un code</x-filament::link>'
        ));
    }

    public function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                $this->getEmailFormComponent(),
                $this->getCodeFormComponent(),
                $this->getPasswordFormComponent(),
                $this->getPasswordConfirmationFormComponent(),
            ]);
    }

    protected function getEmailFormComponent(): Component
    {
        return TextInput::make('email')
            ->label('Adresse e-mail')
            ->email()
            ->disabled(filled($this->email))
            ->dehydrated()
            ->required()
            ->autofocus(blank($this->email));
    }

    protected function getCodeFormComponent(): Component
    {
        return TextInput::make('code')
            ->label('Code OTP')
            ->numeric()
            ->length(6)
            ->required()
            ->autocomplete('one-time-code')
            ->autofocus(filled($this->email));
    }

    protected function getPasswordFormComponent(): Component
    {
        return TextInput::make('password')
            ->label('Nouveau mot de passe')
            ->password()
            ->autocomplete('new-password')
            ->revealable(filament()->arePasswordsRevealable())
            ->required()
            ->rule(PasswordRule::default())
            ->same('passwordConfirmation')
            ->validationAttribute('mot de passe');
    }

    protected function getPasswordConfirmationFormComponent(): Component
    {
        return TextInput::make('passwordConfirmation')
            ->label('Confirmer le mot de passe')
            ->password()
            ->autocomplete('new-password')
            ->revealable(filament()->arePasswordsRevealable())
            ->required()
            ->dehydrated(false);
    }

    public function getResetPasswordFormAction(): Action
    {
        return Action::make('resetPassword')
            ->label('Réinitialiser le mot de passe')
            ->submit('resetPassword');
    }

    public function resendAction(): Action
    {
        return Action::make('resend')
            ->label('Renvoyer le code')
            ->link()
            ->action('resendCode');
    }

    public function resendCode(): void
    {
        try {
            $this->rateLimit(3);
        } catch (TooManyRequestsException $exception) {
            $this->getRateLimitedNotification($exception)?->send();

            return;
        }

        $email = strtolower(trim((string) ($this->email ?: ($this->form->getState()['email'] ?? ''))));

        if (blank($email)) {
            Notification::make()
                ->title('Indiquez votre adresse e-mail.')
                ->danger()
                ->send();

            return;
        }

        try {
            $result = app(AdminPasswordResetService::class)->resend($email);
        } catch (ValidationException $exception) {
            $message = collect($exception->errors())->flatten()->first()
                ?? 'Impossible de renvoyer le code pour le moment.';

            Notification::make()
                ->title($message)
                ->danger()
                ->send();

            return;
        }

        Notification::make()
            ->title($result['message'])
            ->success()
            ->send();
    }

    public function resetPassword(): ?PasswordResetResponse
    {
        try {
            $this->rateLimit(5);
        } catch (TooManyRequestsException $exception) {
            $this->getRateLimitedNotification($exception)?->send();

            return null;
        }

        $data = $this->form->getState();
        $email = strtolower(trim((string) ($this->email ?: ($data['email'] ?? ''))));
        $code = (string) ($data['code'] ?? '');
        $password = (string) ($data['password'] ?? '');

        try {
            app(AdminPasswordResetService::class)->reset($email, $code, $password);
        } catch (ValidationException $exception) {
            $message = collect($exception->errors())->flatten()->first();

            if ($message) {
                Notification::make()
                    ->title($message)
                    ->danger()
                    ->send();
            }

            throw $exception;
        } catch (RuntimeException $exception) {
            Notification::make()
                ->title($exception->getMessage())
                ->danger()
                ->send();

            return null;
        }

        Notification::make()
            ->title(AdminPasswordResetService::SUCCESS_RESET_MESSAGE)
            ->success()
            ->send();

        return app(PasswordResetResponse::class);
    }
}
