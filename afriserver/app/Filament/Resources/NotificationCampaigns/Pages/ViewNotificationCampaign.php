<?php

namespace App\Filament\Resources\NotificationCampaigns\Pages;

use App\Filament\Resources\NotificationCampaigns\NotificationCampaignResource;
use App\Filament\Resources\NotificationCampaigns\Widgets\NotificationCampaignDeliveryStats;
use App\Models\NotificationCampaign;
use Filament\Actions\EditAction;
use Filament\Resources\Pages\ViewRecord;

class ViewNotificationCampaign extends ViewRecord
{
    protected static string $resource = NotificationCampaignResource::class;

    protected function getHeaderActions(): array
    {
        return [
            EditAction::make()
                ->visible(fn (): bool => $this->record instanceof NotificationCampaign
                    && $this->record->isEditable()),
        ];
    }

    protected function getHeaderWidgets(): array
    {
        return [
            NotificationCampaignDeliveryStats::class,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function getWidgetData(): array
    {
        return [
            'record' => $this->getRecord(),
        ];
    }
}
