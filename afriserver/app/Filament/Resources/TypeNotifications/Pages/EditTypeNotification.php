<?php

namespace App\Filament\Resources\TypeNotifications\Pages;

use App\Filament\Resources\TypeNotifications\TypeNotificationResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditTypeNotification extends EditRecord
{
    protected static string $resource = TypeNotificationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
