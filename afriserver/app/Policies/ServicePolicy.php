<?php

namespace App\Policies;

class ServicePolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'services';
    }
}
