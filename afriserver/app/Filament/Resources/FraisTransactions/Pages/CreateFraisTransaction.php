<?php

namespace App\Filament\Resources\FraisTransactions\Pages;

use App\Filament\Resources\FraisTransactions\FraisTransactionResource;
use App\Http\Requests\Admin\StoreFraisTransactionRequest;
use App\Models\FraisTransaction;
use App\Services\ObservabilityService;
use App\Support\ValidatesWithFormRequest;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Database\Eloquent\Model;

class CreateFraisTransaction extends CreateRecord
{
    protected static string $resource = FraisTransactionResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        $validated = ValidatesWithFormRequest::validated(StoreFraisTransactionRequest::class, $data);

        return [
            ...$validated,
            'statut' => $validated['statut'] ?? FraisTransaction::STATUT_ACTIF,
            'pays_id' => $validated['pays_id'] ?? null,
        ];
    }

    protected function handleRecordCreation(array $data): Model
    {
        /** @var FraisTransaction $record */
        $record = static::getModel()::query()->create($data);

        app(ObservabilityService::class)->action(
            category: 'frais',
            action: 'frais.created',
            message: 'Règle de frais de transaction créée',
            context: ['frais_transaction_id' => $record->id],
            dataBefore: null,
            dataAfter: $record->only([
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
}
