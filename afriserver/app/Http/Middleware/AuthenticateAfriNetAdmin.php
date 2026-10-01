<?php

namespace App\Http\Middleware;

use Filament\Facades\Filament;
use Filament\Http\Middleware\Authenticate as FilamentAuthenticate;
use Filament\Models\Contracts\FilamentUser;
use Filament\Notifications\Notification;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Database\Eloquent\Model;

class AuthenticateAfriNetAdmin extends FilamentAuthenticate
{
    /**
     * @param  array<string>  $guards
     */
    protected function authenticate($request, array $guards): void
    {
        $guard = Filament::auth();

        if (! $guard->check()) {
            $this->unauthenticated($request, $guards);

            return;
        }

        $this->auth->shouldUse(Filament::getAuthGuard());

        /** @var Model $user */
        $user = $guard->user();

        $panel = Filament::getCurrentOrDefaultPanel();

        $canAccess = $user instanceof FilamentUser
            ? $user->canAccessPanel($panel)
            : config('app.env') === 'local';

        if ($canAccess) {
            return;
        }

        $guard->logout();

        if ($request->hasSession()) {
            $request->session()->invalidate();
            $request->session()->regenerateToken();
        }

        Notification::make()
            ->title('Accès non autorisé')
            ->body('Vous n\'êtes pas autorisé à accéder à cet espace. Veuillez essayer avec un autre compte.')
            ->danger()
            ->send();

        throw new AuthenticationException(
            'Unauthenticated.',
            $guards,
            $this->redirectTo($request),
        );
    }
}
