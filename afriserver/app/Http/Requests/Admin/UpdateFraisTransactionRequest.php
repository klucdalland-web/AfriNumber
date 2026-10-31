<?php

namespace App\Http\Requests\Admin;

use App\Http\Requests\Admin\Concerns\ValidatesFraisTransaction;
use App\Models\FraisTransaction;
use Illuminate\Foundation\Http\FormRequest;

class UpdateFraisTransactionRequest extends FormRequest
{
    use ValidatesFraisTransaction;

    protected function fraisTransactionIdToIgnore(): ?int
    {
        $record = $this->route('record') ?? $this->route('fraisTransaction') ?? $this->route('frais_transaction');

        if ($record instanceof FraisTransaction) {
            return $record->id;
        }

        if (is_numeric($record)) {
            return (int) $record;
        }

        return null;
    }
}
