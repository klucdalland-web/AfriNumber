<?php

namespace App\Policies;

class TypeNotificationPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'type_notifications';
    }
}
