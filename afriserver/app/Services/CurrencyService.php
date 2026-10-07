<?php

namespace App\Services;

use App\Models\Pays;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class CurrencyService
{
    /**
     * The profit margin to add to the exchange rate.
     * Example: 0.03 = +3% margin.
     */
    protected float $margin = 0.03;

    /**
     * Convert USD amount to local currency.
     */
    public function convertUsdToLocal(float $usdAmount, Pays $pays): float
    {
        return $usdAmount * $pays->exchange_rate;
    }

    /**
     * Convert local currency amount back to USD.
     */
    public function convertLocalToUsd(float $localAmount, Pays $pays): float
    {
        if ($pays->exchange_rate <= 0) {
            return 0;
        }
        return $localAmount / $pays->exchange_rate;
    }

    /**
     * Update all exchange rates using a public API.
     * We use 'exchangerate-api.com' as a reliable source.
     */
    public function updateAllRates(): array
    {
        try {
            // Fetch latest rates relative to USD
            $response = Http::get('https://open.er-api.com/v6/latest/USD');

            if ($response->failed()) {
                throw new \Exception('Failed to fetch exchange rates from API.');
            }

            $rates = $response->json()['rates'] ?? [];
            $updatedCount = 0;

            $pays = Pays::all();
            foreach ($pays as $paysModel) {
                $currency = strtoupper($paysModel->currency_code);

                if ($currency && isset($rates[$currency])) {
                    $marketRate = $rates[$currency];

                    // Apply profit margin: market_rate * (1 + margin)
                    // This ensures we charge slightly more than the market rate.
                    $finalRate = $marketRate * (1 + $this->margin);

                    $paysModel->update([
                        'exchange_rate' => $finalRate
                    ]);
                    $updatedCount++;
                }
            }

            return [
                'success' => true,
                'updated_countries' => $updatedCount,
                'total_countries' => $pays->count(),
            ];
        } catch (\Exception $e) {
            Log::error('CurrencyService updateAllRates Exception: ' . $e->getMessage());
            return [
                'success' => false,
                'error' => $e->getMessage(),
            ];
        }
    }
}
