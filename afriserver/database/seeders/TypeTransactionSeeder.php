<?php

namespace Database\Seeders;

use App\Models\TypeTransaction;
use Illuminate\Database\Seeder;

class TypeTransactionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            [
                'code' => TypeTransaction::CODE_SUBSCRIPTION,
                'label' => 'Abonnement',
                'description' => 'Paiement d\'un nouvel abonnement',
                'sort_order' => 1,
            ],
            [
                'code' => TypeTransaction::CODE_RENEWAL,
                'label' => 'Renouvellement',
                'description' => 'Renouvellement d\'un abonnement existant',
                'sort_order' => 2,
            ],
            [
                'code' => TypeTransaction::CODE_UPGRADE,
                'label' => 'Upgrade',
                'description' => 'Passage vers un plan supérieur',
                'sort_order' => 3,
            ],
            [
                'code' => TypeTransaction::CODE_NUMBER,
                'label' => 'Achat numéro',
                'description' => 'Paiement / achat d\'un numéro virtuel',
                'sort_order' => 4,
            ],
            [
                'code' => TypeTransaction::CODE_FORFAIT,
                'label' => 'Achat forfait',
                'description' => 'Achat d\'un forfait (SMS, appels…)',
                'sort_order' => 5,
            ],
        ];

        foreach ($types as $type) {
            TypeTransaction::query()->updateOrCreate(
                ['code' => $type['code']],
                $type + ['actif' => true],
            );
        }
    }
}
