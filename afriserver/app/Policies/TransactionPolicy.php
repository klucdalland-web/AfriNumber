<?php

namespace App\Policies;

class TransactionPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'transactions';
    }
}
