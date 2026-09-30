<?php

namespace App\Policies;

class PlatformPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'platforms';
    }
}
