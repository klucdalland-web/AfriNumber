<?php

namespace Database\Seeders;

use App\Models\FraisTransaction;
use App\Models\TypeTransaction;
use Illuminate\Database\Seeder;

class FraisTransactionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $defaults = [
            TypeTransaction::CODE_TRANSFER_W2W => [
                'montant_fixe' => '0',
                'taux_pourcentage' => '1',
                'montant_min' => '0.10',
                'montant_max' => null,
            ],
            TypeTransaction::CODE_TRANSFER_W2E => [
                'montant_fixe' => '0',
                'taux_pourcentage' => '1.5',
                'montant_min' => '0.25',
                'montant_max' => null,
            ],
        ];

        foreach ($defaults as $code => $attributes) {
            $type = TypeTransaction::query()->where('code', $code)->first();

            if ($type === null) {
                continue;
            }

            FraisTransaction::query()->updateOrCreate(
                [
                    'type_transaction_id' => $type->id,
                    'pays_id' => null,
                ],
                [
                    ...$attributes,
                    'statut' => FraisTransaction::STATUT_ACTIF,
                ],
            );
        }
    }
}
