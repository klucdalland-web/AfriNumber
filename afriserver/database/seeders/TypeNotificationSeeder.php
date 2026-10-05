<?php

namespace Database\Seeders;

use App\Models\TypeNotification;
use Illuminate\Database\Seeder;

class TypeNotificationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            [
                'code' => TypeNotification::CODE_KYC_APPROVED,
                'label' => 'KYC approuvé',
                'description' => 'Vérification d\'identité acceptée',
                'sort_order' => 1,
            ],
            [
                'code' => TypeNotification::CODE_KYC_REJECTED,
                'label' => 'KYC rejeté',
                'description' => 'Vérification d\'identité refusée',
                'sort_order' => 2,
            ],
            [
                'code' => TypeNotification::CODE_KYC_MANUAL_REVIEW,
                'label' => 'KYC en revue',
                'description' => 'Vérification d\'identité en cours de revue manuelle',
                'sort_order' => 3,
            ],
            [
                'code' => TypeNotification::CODE_GENERAL,
                'label' => 'Communication générale',
                'description' => 'Annonces et informations générales',
                'sort_order' => 4,
            ],
            [
                'code' => TypeNotification::CODE_ALERT,
                'label' => 'Alerte',
                'description' => 'Alerte importante nécessitant l\'attention de l\'utilisateur',
                'sort_order' => 5,
            ],
            [
                'code' => TypeNotification::CODE_SUBSCRIPTION,
                'label' => 'Abonnement',
                'description' => 'Notifications liées à l\'abonnement (expiration, renouvellement…)',
                'sort_order' => 6,
            ],
            [
                'code' => TypeNotification::CODE_PAYMENT,
                'label' => 'Paiement',
                'description' => 'Notifications liées aux paiements et transactions',
                'sort_order' => 7,
            ],
        ];

        foreach ($types as $type) {
            TypeNotification::query()->updateOrCreate(
                ['code' => $type['code']],
                $type + ['actif' => true],
            );
        }
    }
}
