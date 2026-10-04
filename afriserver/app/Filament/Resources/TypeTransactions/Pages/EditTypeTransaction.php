<?php

namespace App\Filament\Resources\TypeTransactions\Pages;

use App\Filament\Resources\TypeTransactions\TypeTransactionResource;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditTypeTransaction extends EditRecord
{
    protected static string $resource = TypeTransactionResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }
}
