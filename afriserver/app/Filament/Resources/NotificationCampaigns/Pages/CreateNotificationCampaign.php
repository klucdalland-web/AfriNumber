<?php

namespace App\Filament\Resources\NotificationCampaigns\Pages;

use App\Filament\Resources\NotificationCampaigns\NotificationCampaignResource;
use App\Models\NotificationCampaign;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\Auth;

class CreateNotificationCampaign extends CreateRecord
{
    protected static string $resource = NotificationCampaignResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $data['sent_by'] = Auth::id();
        $data = $this->normalizeAudienceFields($data);

        $sendMode = $this->data['send_mode'] ?? 'immediate';

        if ($sendMode === 'scheduled' && ! empty($data['scheduled_at'])) {
            $data['status'] = NotificationCampaign::STATUS_SCHEDULED;
        } else {
            $data['status'] = NotificationCampaign::STATUS_QUEUED;
            $data['scheduled_at'] = null;
        }

        if (! in_array(NotificationCampaign::CHANNEL_PUSH, $data['channels'] ?? [], true)) {
            $data['device_scope'] = NotificationCampaign::DEVICE_SCOPE_ALL;
        }

        return $data;
    }

    protected function afterCreate(): void
    {
        /** @var NotificationCampaign $campaign */
        $campaign = $this->record;
        $this->syncAudienceRelations($campaign);
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function normalizeAudienceFields(array $data): array
    {
        $audience = $data['audience_type'] ?? NotificationCampaign::AUDIENCE_ALL_USERS;

        if ($audience !== NotificationCampaign::AUDIENCE_ORGANISATION) {
            $data['organisation_id'] = null;
        }

        if ($audience !== NotificationCampaign::AUDIENCE_PAYS) {
            $data['pays_id'] = null;
        }

        return $data;
    }

    private function syncAudienceRelations(NotificationCampaign $campaign): void
    {
        if ($campaign->audience_type !== NotificationCampaign::AUDIENCE_SELECTED_USERS) {
            $campaign->users()->sync([]);
        }

        if (
            ! $campaign->includesChannel(NotificationCampaign::CHANNEL_PUSH)
            || $campaign->device_scope !== NotificationCampaign::DEVICE_SCOPE_SELECTED
        ) {
            $campaign->devices()->sync([]);
        }
    }
}
