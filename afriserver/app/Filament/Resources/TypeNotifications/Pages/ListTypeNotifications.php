<?php

namespace App\Filament\Resources\TypeNotifications\Pages;

use App\Filament\Resources\TypeNotifications\TypeNotificationResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListTypeNotifications extends ListRecords
{
    protected static string $resource = TypeNotificationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
