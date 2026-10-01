<?php

namespace App\Policies;

class ContinentPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'continents';
    }
}
