<?php

namespace App\Filament\Resources\ObservabilityLogs\Pages;

use App\Filament\Resources\ObservabilityLogs\ObservabilityLogResource;
use Filament\Resources\Pages\ManageRecords;

class ManageObservabilityLogs extends ManageRecords
{
    protected static string $resource = ObservabilityLogResource::class;

    protected function getHeaderActions(): array
    {
        return [];
    }
}
