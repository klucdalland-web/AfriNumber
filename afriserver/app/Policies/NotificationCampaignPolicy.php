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

    public function delete(User $user, mixed $model): bool
    {
        if (! $model instanceof NotificationCampaign) {
            return false;
        }

        if (! in_array($model->status, [
            NotificationCampaign::STATUS_SCHEDULED,
            NotificationCampaign::STATUS_CANCELLED,
            NotificationCampaign::STATUS_FAILED,
        ], true)) {
            return false;
        }

        return parent::delete($user, $model);
    }
}
