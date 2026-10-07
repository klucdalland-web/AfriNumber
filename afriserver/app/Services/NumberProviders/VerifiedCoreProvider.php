<?php

namespace App\Services\NumberProviders;

use App\Contracts\NumberProviderInterface;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class VerifiedCoreProvider implements NumberProviderInterface
{
    protected string $apiKey;
    protected string $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('services.verifiedcore.key');
        $this->baseUrl = config('services.verifiedcore.base_url', 'https://api.verifiedcore.com/v1');
    }

    public function searchNumbers(string $countryCode, string $serviceSlug = 'whatsapp'): array
    {
        try {
            $response = Http::withToken($this->apiKey)
                ->get("{$this->baseUrl}/numbers/search", [
                    'countryCode' => strtoupper($countryCode),
                    'serviceSlug' => $serviceSlug,
                    'minScore' => 80, // We only want high quality numbers by default
                    'limit' => 10
                ]);

            if ($response->failed()) {
                Log::error('VerifiedCore Search API failed: ' . $response->body());
                return [];
            }

            return $response->json() ?? [];
        } catch (\Exception $e) {
            Log::error('VerifiedCore Search Exception: ' . $e->getMessage());
            return [];
        }
    }

    public function purchaseNumber(string $phoneNumber, string $countryCode): array
    {
        try {
            $response = Http::withToken($this->apiKey)
                ->post("{$this->baseUrl}/numbers/purchase", [
                    'phone_number' => $phoneNumber,
                    'country' => strtoupper($countryCode),
                ]);

            if ($response->failed()) {
                Log::error('VerifiedCore Purchase API failed: ' . $response->body());
                return [
                    'success' => false,
                    'message' => 'Purchase failed at provider level.',
                    'error' => $response->json()
                ];
            }

            return array_merge(['success' => true], $response->json());
        } catch (\Exception $e) {
            Log::error('VerifiedCore Purchase Exception: ' . $e->getMessage());
            return [
                'success' => false,
                'message' => 'Internal error during purchase.',
                'error' => $e->getMessage()
            ];
        }
    }
}
