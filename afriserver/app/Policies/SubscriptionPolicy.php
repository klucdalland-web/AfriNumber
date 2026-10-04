<?php

namespace App\Policies;

class SubscriptionPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'subscriptions';
    }
}
