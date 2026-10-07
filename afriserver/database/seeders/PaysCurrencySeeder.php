<?php

namespace Database\Seeders;

use App\Models\Pays;
use Illuminate\Database\Seeder;

class PaysCurrencySeeder extends Seeder
{
    public function run(): void
    {
        // Mapping of country codes to their currency codes
        $currencyMapping = [
            'CD' => 'CDF', // Congo-Kinshasa
            'CG' => 'XAF', // Congo-Brazzaville
            'NG' => 'NGN', // Nigeria
            'CI' => 'XOF', // Côte d'Ivoire
            'SN' => 'XOF', // Sénégal
            'CM' => 'XOF', // Cameroun
            'GA' => 'XOF', // Gabon
            'TD' => 'XAF', // Tchad
            'CF' => 'XAF', // CentrafriqueS
            'MG' => 'MGA', // Madagascar
            'US' => 'USD', // USA
            'FR' => 'EUR', // France
            'GB' => 'GBP', // UK
        ];

        foreach ($currencyMapping as $code => $currency) {
            Pays::where('code', $code)->update([
                'currency_code' => $currency,
            ]);
        }
    }
}
