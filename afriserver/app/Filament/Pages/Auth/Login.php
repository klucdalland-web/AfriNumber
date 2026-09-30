<?php

namespace App\Filament\Pages\Auth;

use Filament\Auth\Pages\Login as BaseLogin;
use Filament\Facades\Filament;
use Filament\Models\Contracts\FilamentUser;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Validation\ValidationException;

class Login extends BaseLogin
{
    protected bool $failedDueToUnauthorizedAccess = false;

    protected function isUserAllowedToAccessPanel(Authenticatable $user): bool
    {
        if (! ($user instanceof FilamentUser)) {
            return true;
        }

        $allowed = $user->canAccessPanel(Filament::getCurrentOrDefaultPanel());

        if (! $allowed) {
            $this->failedDueToUnauthorizedAccess = true;
        }

        return $allowed;
    }

    protected function throwFailureValidationException(): never
    {
        if ($this->failedDueToUnauthorizedAccess) {
            throw ValidationException::withMessages([
                'data.email' => 'Vous n\'êtes pas autorisé à accéder à cet espace. Veuillez essayer avec un autre compte.',
            ]);
        }

        parent::throwFailureValidationException();
    }
}
