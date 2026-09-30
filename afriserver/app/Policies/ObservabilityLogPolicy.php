<?php

namespace App\Policies;

use App\Models\User;
use App\Policies\Concerns\ChecksPermissions;
use App\Support\PanelPermission;

class ObservabilityLogPolicy
{
    use ChecksPermissions;

    public function viewAny(User $user): bool
    {
        return $this->allow($user, PanelPermission::OBSERVABILITY_VIEW);
    }

    public function view(User $user, mixed $model): bool
    {
        return $this->allow($user, PanelPermission::OBSERVABILITY_VIEW);
    }

    public function create(User $user): bool
    {
        return false;
    }

    public function update(User $user, mixed $model): bool
    {
        return false;
    }

    public function delete(User $user, mixed $model): bool
    {
        return $this->allow($user, PanelPermission::OBSERVABILITY_DELETE);
    }

    public function deleteAny(User $user): bool
    {
        return $this->allow($user, PanelPermission::OBSERVABILITY_DELETE);
    }
}
