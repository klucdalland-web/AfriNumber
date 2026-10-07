<?php

namespace App\Services;

use App\Models\Pays;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class CurrencyService
{
    /**
     * Marge ajoutée au taux du marché (0.03 = +3 %).
     */
    protected float $margin = 0.03;

    /**
     * Taux de repli si l'API ne renvoie rien d'exploitable pour une devise.
     */
    protected array $fallbackRates = [
        'XOF' => 610.0,
        'XAF' => 610.0,
        'CDF' => 2800.0,
        'NGN' => 1500.0,
        'MGA' => 4600.0,
        'USD' => 1.0,
        'EUR' => 0.92,
        'GBP' => 0.79,
    ];

    public function convertUsdToLocal(float $usdAmount, Pays $pays): float
    {
        return $usdAmount * $pays->exchange_rate;
    }

    public function convertLocalToUsd(float $localAmount, Pays $pays): float
    {
        if ($pays->exchange_rate <= 0) {
            return 0;
        }

        return $localAmount / $pays->exchange_rate;
    }

    public function updateAllRates(): array
    {
        try {
            $response = Http::timeout(15)->get('https://open.er-api.com/v6/latest/USD');

            if ($response->failed()) {
                throw new \Exception('Failed to fetch exchange rates from API (HTTP '.$response->status().').');
            }

            $rates = $response->json('rates') ?? [];
            $updatedCount = 0;

            $pays = Pays::all();

            foreach ($pays as $paysModel) {
                $currency = strtoupper((string) $paysModel->currency_code);

                if ($currency === '') {
                    continue;
                }

                $marketRate = $rates[$currency] ?? null;

                // Taux absent, nul, ou exactement 1.0 pour une devise autre que l'USD :
                // on bascule sur le taux de repli. Les vrais taux inférieurs à 1
                // (EUR, GBP...) sont conservés.
                if ($marketRate === null
                    || $marketRate <= 0
                    || ($currency !== 'USD' && abs($marketRate - 1.0) < 0.0001)) {
                    $marketRate = $this->fallbackRates[$currency] ?? null;
                }

                // Aucune source fiable : on ne touche pas au taux existant.
                if ($marketRate === null) {
                    Log::warning("CurrencyService : aucun taux pour {$currency} (pays {$paysModel->code}).");

                    continue;
                }

                $paysModel->update([
                    'exchange_rate' => $marketRate * (1 + $this->margin),
                ]);

                $updatedCount++;
            }

            return [
                'success' => true,
                'updated_countries' => $updatedCount,
                'total_countries' => $pays->count(),
            ];
        } catch (\Exception $e) {
            Log::error('CurrencyService updateAllRates Exception: '.$e->getMessage());

            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}