<?php

namespace App\Policies;

class PaysPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'pays';
    }
}
