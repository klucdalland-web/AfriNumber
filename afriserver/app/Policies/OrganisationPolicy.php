<?php

namespace App\Policies;

class OrganisationPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'organisations';
    }
}
