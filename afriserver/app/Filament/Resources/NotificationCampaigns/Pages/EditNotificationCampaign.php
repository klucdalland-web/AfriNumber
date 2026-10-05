<?php

namespace App\Filament\Resources\NotificationCampaigns\Pages;

use App\Filament\Resources\NotificationCampaigns\NotificationCampaignResource;
use App\Models\NotificationCampaign;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Actions\ViewAction;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\EditRecord;

class EditNotificationCampaign extends EditRecord
{
    protected static string $resource = NotificationCampaignResource::class;

    protected function getHeaderActions(): array
    {
        return [
            ViewAction::make(),
            Action::make('cancelCampaign')
                ->label('Annuler la campagne')
                ->color('danger')
                ->requiresConfirmation()
                ->visible(fn (): bool => $this->record instanceof NotificationCampaign
                    && $this->record->status === NotificationCampaign::STATUS_SCHEDULED)
                ->action(function (): void {
                    /** @var NotificationCampaign $campaign */
                    $campaign = $this->record;
                    $campaign->update(['status' => NotificationCampaign::STATUS_CANCELLED]);

                    Notification::make()
                        ->title('Campagne annulée')
                        ->success()
                        ->send();

                    $this->redirect(NotificationCampaignResource::getUrl('view', ['record' => $campaign]));
                }),
            DeleteAction::make()
                ->visible(fn (): bool => $this->record instanceof NotificationCampaign
                    && $this->record->isEditable()),
        ];
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeFill(array $data): array
    {
        $data['send_mode'] = ! empty($data['scheduled_at']) ? 'scheduled' : 'immediate';

        return $data;
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
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

    protected function afterSave(): void
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
