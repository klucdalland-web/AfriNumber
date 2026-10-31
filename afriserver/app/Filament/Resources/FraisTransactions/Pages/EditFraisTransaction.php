<?php

namespace App\Filament\Resources\FraisTransactions\Pages;

use App\Filament\Resources\FraisTransactions\FraisTransactionResource;
use App\Http\Requests\Admin\UpdateFraisTransactionRequest;
use App\Models\FraisTransaction;
use App\Services\ObservabilityService;
use App\Support\ValidatesWithFormRequest;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Database\Eloquent\Model;

class EditFraisTransaction extends EditRecord
{
    protected static string $resource = FraisTransactionResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        /** @var FraisTransaction $record */
        $record = $this->getRecord();

        $validated = ValidatesWithFormRequest::validated(
            UpdateFraisTransactionRequest::class,
            $data,
            $record,
        );

        return [
            ...$validated,
            'pays_id' => $validated['pays_id'] ?? null,
        ];
    }

    protected function handleRecordUpdate(Model $record, array $data): Model
    {
        /** @var FraisTransaction $record */
        $before = $record->only([
            'id',
            'type_transaction_id',
            'pays_id',
            'montant_fixe',
            'taux_pourcentage',
            'montant_min',
            'montant_max',
            'statut',
        ]);

        $record->update($data);

        app(ObservabilityService::class)->action(
            category: 'frais',
            action: 'frais.updated',
            message: 'Règle de frais de transaction modifiée',
            context: ['frais_transaction_id' => $record->id],
            dataBefore: $before,
            dataAfter: $record->fresh()?->only([
                'id',
                'type_transaction_id',
                'pays_id',
                'montant_fixe',
                'taux_pourcentage',
                'montant_min',
                'montant_max',
                'statut',
            ]),
            user: auth()->user(),
        );

        return $record;
    }

    protected function getHeaderActions(): array
    {
        return [];
    }
}
