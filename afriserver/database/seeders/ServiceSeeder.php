<?php

namespace Database\Seeders;

use App\Models\Service;
use Illuminate\Database\Seeder;

class ServiceSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $services = [
            [
                'code' => 'virtual_number',
                'label' => 'Numéro virtuel',
                'description' => 'Attribution et gestion de numéros virtuels',
            ],
            [
                'code' => 'sms_in',
                'label' => 'SMS entrants',
                'description' => 'Réception de SMS sur les numéros attribués',
            ],
            [
                'code' => 'calls',
                'label' => 'Appels',
                'description' => 'Réception d’appels sur les numéros attribués',
            ],
            [
                'code' => 'multi_country',
                'label' => 'Multi-pays',
                'description' => 'Numéros dans plusieurs pays',
            ],
        ];

        foreach ($services as $service) {
            Service::query()->updateOrCreate(
                ['code' => $service['code']],
                $service + ['is_active' => true],
            );
        }
    }
}
