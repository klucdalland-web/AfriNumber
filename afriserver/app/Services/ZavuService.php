<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class ZavuService
{
    protected string $apiKey;
    protected string $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('services.zavu.key');
        $this->baseUrl = config('services.zavu.base_url', 'https://zavu.dev');
    }

    /**
     * Rechercher les numéros virtuels disponibles par pays.
     */
    public function searchAvailableNumbers(string $countryCode)
    {
        $response = Http::withToken($this->apiKey)
            ->get("{$this->baseUrl}/phone-numbers/available", [
                'country' => strtoupper($countryCode),
                'limit' => 5
            ]);

        return $response->json();
    }

    /**
     * Louer/Acheter un numéro de téléphone spécifique.
     */
    public function purchaseNumber(string $phoneNumber, string $countryCode)
    {
        $response = Http::withToken($this->apiKey)
            ->post("{$this->baseUrl}/phone-numbers", [
                'phone_number' => $phoneNumber,
                'country' => strtoupper($countryCode),
            ]);

        return $response->json();
    }
}
