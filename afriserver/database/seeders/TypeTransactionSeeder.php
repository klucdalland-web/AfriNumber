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
                'code' => TypeTransaction::CODE_TOPUP,
                'label' => 'Rechargement',
                'description' => 'Rechargement du solde wallet',
                'sort_order' => 6,
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
            [
                'code' => TypeTransaction::CODE_TRANSFER_W2W,
                'label' => 'Transfert wallet → wallet',
                'description' => 'Transfert interne entre deux comptes AfriNumber',
                'sort_order' => 7,
            ],
            [
                'code' => TypeTransaction::CODE_TRANSFER_W2E,
                'label' => 'Transfert wallet → externe',
                'description' => 'Sortie vers MoMo / banque via PSP',
                'sort_order' => 8,
            ],
            [
                'code' => TypeTransaction::CODE_FEE,
                'label' => 'Frais',
                'description' => 'Frais liés à une opération parente',
                'sort_order' => 9,
            ],
            [
                'code' => TypeTransaction::CODE_REFUND,
                'label' => 'Remboursement',
                'description' => 'Remboursement crédité sur le wallet',
                'sort_order' => 10,
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
