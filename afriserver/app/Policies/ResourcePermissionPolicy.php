<?php

namespace App\Policies;

use App\Models\User;

/**
 * Base policy for Filament domain resources.
 *
 * Extend and set $permissionPrefix to the PanelPermission resource key
 * (e.g. "users", "pays"). Methods map to Spatie permissions:
 * "{prefix}.view|create|update|delete".
 */
abstract class ResourcePermissionPolicy
{
    use Concerns\ChecksPermissions;

    abstract protected function permissionPrefix(): string;

    public function viewAny(User $user): bool
    {
        return $this->allow($user, $this->permissionPrefix().'.view');
    }

    public function view(User $user, mixed $model): bool
    {
        return $this->allow($user, $this->permissionPrefix().'.view');
    }

    public function create(User $user): bool
    {
        return $this->allow($user, $this->permissionPrefix().'.create');
    }

    public function update(User $user, mixed $model): bool
    {
        return $this->allow($user, $this->permissionPrefix().'.update');
    }

    public function delete(User $user, mixed $model): bool
    {
        return $this->allow($user, $this->permissionPrefix().'.delete');
    }

    public function deleteAny(User $user): bool
    {
        return $this->allow($user, $this->permissionPrefix().'.delete');
    }
}
