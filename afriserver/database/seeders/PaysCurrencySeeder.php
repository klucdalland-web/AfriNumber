<?php

namespace Database\Seeders;

use App\Models\Devise;
use App\Models\Pays;
use Illuminate\Database\Seeder;

class PaysCurrencySeeder extends Seeder
{
    public function run(): void
    {
        // Mapping code pays ISO → code devise + taux indicatif (vers USD)
        $currencyMapping = [
            'CD' => ['currency' => 'CDF', 'rate' => 2800],
            'CG' => ['currency' => 'XAF', 'rate' => 600],
            'NG' => ['currency' => 'NGN', 'rate' => 1600],
            'CI' => ['currency' => 'XOF', 'rate' => 600],
            'SN' => ['currency' => 'XOF', 'rate' => 600],
            'CM' => ['currency' => 'XAF', 'rate' => 600],
            'GA' => ['currency' => 'XAF', 'rate' => 600],
            'TD' => ['currency' => 'XAF', 'rate' => 600],
            'CF' => ['currency' => 'XAF', 'rate' => 600],
            'MG' => ['currency' => 'MGA', 'rate' => 4500],
            'US' => ['currency' => 'USD', 'rate' => 1],
            'FR' => ['currency' => 'EUR', 'rate' => 0.92],
            'GB' => ['currency' => 'GBP', 'rate' => 0.79],
        ];

        $devises = Devise::query()->pluck('id', 'code');

        foreach ($currencyMapping as $code => $data) {
            $deviseId = $devises[$data['currency']] ?? null;
            $symbole = Devise::query()->where('code', $data['currency'])->value('symbole');

            Pays::where('code', $code)->update([
                'currency_code' => $data['currency'],
                'currency_symbol' => $symbole,
                'exchange_rate' => $data['rate'],
                'devise_id' => $deviseId,
            ]);
        }

        // Relie les autres pays déjà pourvus d'un currency_code à leur devise
        Pays::query()
            ->whereNotNull('currency_code')
            ->whereNull('devise_id')
            ->each(function (Pays $pays) use ($devises): void {
                $deviseId = $devises[$pays->currency_code] ?? null;
                if ($deviseId === null) {
                    return;
                }

                $pays->update([
                    'devise_id' => $deviseId,
                    'currency_symbol' => Devise::query()->whereKey($deviseId)->value('symbole'),
                ]);
            });
    }
}
