<?php

namespace App\Services\NumberProviders;

use App\Contracts\NumberProviderInterface;

/**
 * Mock provider for testing purposes.
 * Returns fake data without calling any external API.
 */
class MockNumberProvider implements NumberProviderInterface
{
    public function searchNumbers(string $countryCode, string $serviceSlug = 'whatsapp'): array
    {
        // Simulating a list of available numbers
        return [
            [
                'numberId' => 'mock_num_1',
                'number' => '+ ' . ($countryCode === 'NG' ? '234' : '1') . ' 800 000 0001',
                'countryCode' => $countryCode,
                'countryName' => 'Test Country',
                'healthScore' => 95,
                'numberType' => 'PHYSICAL_SIM',
                'price' => 0.40,
                'deliveryRate' => 98,
                'avgLatencyMs' => 1200,
                'available' => true,
            ],
            [
                'numberId' => 'mock_num_2',
                'number' => '+ ' . ($countryCode === 'NG' ? '234' : '1') . ' 800 000 0002',
                'countryCode' => $countryCode,
                'countryName' => 'Test Country',
                'healthScore' => 82,
                'numberType' => 'VOIP',
                'price' => 0.20,
                'deliveryRate' => 85,
                'avgLatencyMs' => 3000,
                'available' => true,
            ],
        ];
    }

    public function purchaseNumber(string $phoneNumber, string $countryCode): array
    {
        return [
            'success' => true,
            'message' => 'Mock Purchase Successful!',
            'data' => [
                'number' => $phoneNumber,
                'status' => 'active',
                'provider' => 'MockProvider'
            ]
        ];
    }
}
