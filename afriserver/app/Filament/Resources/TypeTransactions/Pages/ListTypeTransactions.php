<?php

namespace App\Filament\Resources\TypeTransactions\Pages;

use App\Filament\Resources\TypeTransactions\TypeTransactionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListTypeTransactions extends ListRecords
{
    protected static string $resource = TypeTransactionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
