<?php

namespace App\Policies;

use App\Models\NotificationCampaign;
use App\Models\User;

class NotificationCampaignPolicy extends ResourcePermissionPolicy
{
    protected function permissionPrefix(): string
    {
        return 'notification_campaigns';
    }

    public function update(User $user, mixed $model): bool
    {
        if (! $model instanceof NotificationCampaign || ! $model->isEditable()) {
            return false;
        }

        return parent::update($user, $model);
    }
}
