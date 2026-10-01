<?php

namespace App\Policies;

use App\Models\User;
use App\Policies\Concerns\ChecksPermissions;
use App\Support\PanelPermission;
use Spatie\Permission\Models\Role;

class RolePolicy
{
    use ChecksPermissions;

    public function viewAny(User $user): bool
    {
        return $this->allow($user, PanelPermission::ROLES_VIEW);
    }

    public function view(User $user, Role $role): bool
    {
        return $this->allow($user, PanelPermission::ROLES_VIEW);
    }

    public function create(User $user): bool
    {
        return $this->allow($user, PanelPermission::ROLES_CREATE);
    }

    public function update(User $user, Role $role): bool
    {
        return $this->allow($user, PanelPermission::ROLES_UPDATE);
    }

    public function delete(User $user, Role $role): bool
    {
        if ($role->name === 'super_admin') {
            return false;
        }

        return $this->allow($user, PanelPermission::ROLES_DELETE);
    }

    public function deleteAny(User $user): bool
    {
        return $this->allow($user, PanelPermission::ROLES_DELETE);
    }
}
