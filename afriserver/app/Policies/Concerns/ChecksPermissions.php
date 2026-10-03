<?php

namespace App\Policies\Concerns;

use App\Models\User;

trait ChecksPermissions
{
    protected function allow(User $user, string $permission): bool
    {
        return $user->can($permission);
    }
}
