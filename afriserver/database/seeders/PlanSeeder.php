<?php

namespace Database\Seeders;

use App\Models\Plan;
use App\Models\Service;
use Illuminate\Database\Seeder;

class PlanSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $services = Service::query()->pluck('id', 'code');

        $plans = [
            [
                'code' => 'free',
                'label' => 'Free',
                'description' => 'Essai : 1 numéro virtuel pendant 14 jours',
                'price' => 0,
                'currency' => 'XOF',
                'duration_days' => 14,
                'max_numbers' => 1,
                'sort_order' => 0,
                'services' => [
                    'virtual_number' => null,
                ],
            ],
            [
                'code' => 'basic',
                'label' => 'Basic',
                'description' => '1 numéro virtuel avec SMS entrants',
                'price' => 2500,
                'currency' => 'XOF',
                'duration_days' => 30,
                'max_numbers' => 1,
                'sort_order' => 1,
                'services' => [
                    'virtual_number' => null,
                    'sms_in' => 100,
                ],
            ],
            [
                'code' => 'pro',
                'label' => 'Pro',
                'description' => 'Plusieurs numéros, SMS, appels et multi-pays',
                'price' => 10000,
                'currency' => 'XOF',
                'duration_days' => 30,
                'max_numbers' => 5,
                'sort_order' => 2,
                'services' => [
                    'virtual_number' => null,
                    'sms_in' => 1000,
                    'calls' => 200,
                    'multi_country' => null,
                ],
            ],
        ];

        foreach ($plans as $planData) {
            $serviceQuotas = $planData['services'];
            unset($planData['services']);

            $plan = Plan::query()->updateOrCreate(
                ['code' => $planData['code']],
                $planData + ['is_active' => true],
            );

            $sync = [];
            foreach ($serviceQuotas as $code => $quota) {
                if (! isset($services[$code])) {
                    continue;
                }

                $sync[$services[$code]] = ['quota' => $quota];
            }

            $plan->services()->sync($sync);
        }
    }
}
