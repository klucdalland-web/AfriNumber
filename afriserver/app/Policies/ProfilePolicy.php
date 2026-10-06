<?php

namespace App\Policies;

class ProfilePolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'profiles';
    }
}
