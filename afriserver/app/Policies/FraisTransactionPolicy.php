<?php

namespace App\Policies;

use App\Models\FraisTransaction;
use App\Models\User;
use App\Support\PanelPermission;

class FraisTransactionPolicy
{
    use Concerns\ChecksPermissions;

    public function viewAny(User $user): bool
    {
        return $this->allow($user, PanelPermission::FRAIS_GERER);
    }

    public function view(User $user, FraisTransaction $fraisTransaction): bool
    {
        return $this->allow($user, PanelPermission::FRAIS_GERER);
    }

    public function create(User $user): bool
    {
        return $this->allow($user, PanelPermission::FRAIS_GERER);
    }

    public function update(User $user, FraisTransaction $fraisTransaction): bool
    {
        return $this->allow($user, PanelPermission::FRAIS_GERER);
    }

    public function delete(User $user, FraisTransaction $fraisTransaction): bool
    {
        return false;
    }

    public function deleteAny(User $user): bool
    {
        return false;
    }

    public function restore(User $user, FraisTransaction $fraisTransaction): bool
    {
        return false;
    }

    public function forceDelete(User $user, FraisTransaction $fraisTransaction): bool
    {
        return false;
    }
}
