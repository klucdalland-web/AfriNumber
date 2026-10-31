<?php

namespace App\Http\Requests\Admin\Concerns;

use App\Models\FraisTransaction;
use App\Support\PanelPermission;
use Illuminate\Validation\Validator;

trait ValidatesFraisTransaction
{
    public function authorize(): bool
    {
        return $this->user()?->can(PanelPermission::FRAIS_GERER) ?? false;
    }

    /**
     * @return array<string, list<string>>
     */
    public function rules(): array
    {
        return [
            'type_transaction_id' => ['required', 'integer', 'exists:type_transactions,id'],
            'pays_id' => ['nullable', 'integer', 'exists:pays,id'],
            'montant_fixe' => ['required', 'numeric', 'min:0'],
            'taux_pourcentage' => ['required', 'numeric', 'min:0', 'max:100'],
            'montant_min' => ['nullable', 'numeric', 'min:0'],
            'montant_max' => ['nullable', 'numeric', 'gte:montant_min'],
            'statut' => ['sometimes', 'in:ACTIF,INACTIF'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'type_transaction_id.required' => 'Le type de transaction est obligatoire.',
            'type_transaction_id.exists' => 'Le type de transaction sélectionné est invalide.',
            'pays_id.exists' => 'Le pays sélectionné est invalide.',
            'montant_fixe.required' => 'Le montant fixe est obligatoire.',
            'montant_fixe.numeric' => 'Le montant fixe doit être un nombre.',
            'montant_fixe.min' => 'Le montant fixe doit être supérieur ou égal à 0.',
            'taux_pourcentage.required' => 'Le taux de pourcentage est obligatoire.',
            'taux_pourcentage.numeric' => 'Le taux de pourcentage doit être un nombre.',
            'taux_pourcentage.min' => 'Le taux de pourcentage doit être supérieur ou égal à 0.',
            'taux_pourcentage.max' => 'Le taux de pourcentage ne peut pas dépasser 100.',
            'montant_min.numeric' => 'Le montant minimum doit être un nombre.',
            'montant_min.min' => 'Le montant minimum doit être supérieur ou égal à 0.',
            'montant_max.numeric' => 'Le montant maximum doit être un nombre.',
            'montant_max.gte' => 'Le montant maximum doit être supérieur ou égal au montant minimum.',
            'statut.in' => 'Le statut doit être ACTIF ou INACTIF.',
        ];
    }

    /**
     * @return list<\Closure(Validator): void>
     */
    public function after(): array
    {
        return [
            function (Validator $validator): void {
                if ($validator->errors()->hasAny(['type_transaction_id', 'pays_id'])) {
                    return;
                }

                if ($this->filled('pays_id')) {
                    return;
                }

                $query = FraisTransaction::query()
                    ->where('type_transaction_id', $this->integer('type_transaction_id'))
                    ->whereNull('pays_id');

                $ignoreId = $this->fraisTransactionIdToIgnore();

                if ($ignoreId !== null) {
                    $query->whereKeyNot($ignoreId);
                }

                if ($query->exists()) {
                    $validator->errors()->add(
                        'pays_id',
                        'Une règle par défaut (tous les pays) existe déjà pour ce type de transaction.',
                    );
                }
            },
        ];
    }

    protected function fraisTransactionIdToIgnore(): ?int
    {
        return null;
    }
}
