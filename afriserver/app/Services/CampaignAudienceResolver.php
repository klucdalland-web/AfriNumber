<?php

namespace App\Services;

use App\Models\Device;
use App\Models\NotificationCampaign;
use App\Models\User;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Collection;

class CampaignAudienceResolver
{
    /**
     * @return Collection<int, User>
     */
    public function resolveUsers(NotificationCampaign $campaign): Collection
    {
        $query = User::query()
            ->where('statut', 'actif')
            ->whereHas('typeUser', fn (Builder $q) => $q->where('code', 'user'));

        return match ($campaign->audience_type) {
            NotificationCampaign::AUDIENCE_SELECTED_USERS => $query
                ->whereIn('id', $campaign->users()->pluck('users.id'))
                ->get(),
            NotificationCampaign::AUDIENCE_ORGANISATION => $query
                ->whereHas('pays', fn (Builder $q) => $q->where('organisation_id', $campaign->organisation_id))
                ->get(),
            NotificationCampaign::AUDIENCE_PAYS => $query
                ->where('pays_id', $campaign->pays_id)
                ->get(),
            default => $query->get(),
        };
    }

    /**
     * @param  Collection<int, User>  $users
     * @return array<int, list<int>> user_id => device_ids
     */
    public function resolveDevicesByUser(NotificationCampaign $campaign, Collection $users): array
    {
        if (! $campaign->includesChannel(NotificationCampaign::CHANNEL_PUSH)) {
            return [];
        }

        $userIds = $users->pluck('id')->all();

        if ($campaign->device_scope === NotificationCampaign::DEVICE_SCOPE_SELECTED) {
            $selectedIds = $campaign->devices()->pluck('devices.id')->all();

            $devices = Device::query()
                ->where('actif', true)
                ->whereIn('user_id', $userIds)
                ->whereIn('id', $selectedIds)
                ->get(['id', 'user_id']);
        } else {
            $devices = Device::query()
                ->where('actif', true)
                ->whereIn('user_id', $userIds)
                ->get(['id', 'user_id']);
        }

        $map = [];
        foreach ($devices as $device) {
            $map[$device->user_id][] = (int) $device->id;
        }

        return $map;
    }
}
