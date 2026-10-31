<?php

namespace App\Filament\Resources\FraisTransactions\Pages;

use App\Filament\Resources\FraisTransactions\FraisTransactionResource;
use Filament\Actions\CreateAction;
use Filament\Resources\Pages\ListRecords;

class ListFraisTransactions extends ListRecords
{
    protected static string $resource = FraisTransactionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make(),
        ];
    }
}
