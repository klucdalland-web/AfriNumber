<?php

namespace Database\Seeders;

use App\Models\Devise;
use Illuminate\Database\Seeder;

class DeviseSeeder extends Seeder
{
    public function run(): void
    {
        $devises = [
            ['code' => 'XAF', 'label' => 'Franc CFA BEAC', 'symbole' => 'FCFA'],
            ['code' => 'XOF', 'label' => 'Franc CFA UEMOA', 'symbole' => 'FCFA'],
            ['code' => 'USD', 'label' => 'Dollar américain', 'symbole' => '$'],
            ['code' => 'EUR', 'label' => 'Euro', 'symbole' => '€'],
            ['code' => 'CDF', 'label' => 'Franc congolais', 'symbole' => 'FC'],
            ['code' => 'NGN', 'label' => 'Naira nigérian', 'symbole' => '₦'],
            ['code' => 'MGA', 'label' => 'Ariary malgache', 'symbole' => 'Ar'],
            ['code' => 'GBP', 'label' => 'Livre sterling', 'symbole' => '£'],
        ];

        foreach ($devises as $devise) {
            Devise::query()->updateOrCreate(
                ['code' => $devise['code']],
                [
                    'label' => $devise['label'],
                    'symbole' => $devise['symbole'],
                    'actif' => true,
                ]
            );
        }
    }
}
