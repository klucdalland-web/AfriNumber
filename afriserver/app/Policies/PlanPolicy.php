<?php

namespace App\Policies;

class PlanPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'plans';
    }
}
