<?php

namespace App\Policies;

use App\Models\User;
use App\Support\PanelPermission;

class UserPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'users';
    }

    public function assignRoles(User $user): bool
    {
        return $this->allow($user, PanelPermission::ROLES_UPDATE)
            || $this->allow($user, PanelPermission::USERS_UPDATE);
    }
}
