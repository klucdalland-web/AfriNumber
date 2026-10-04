<?php

namespace App\Policies;

class TypeTransactionPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'type_transactions';
    }
}
