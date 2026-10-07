<?php

namespace App\Contracts;

/**
 * Interface defining the standard for virtual number providers.
 * This allows the app to switch between different providers (Zavu, VerifiedCore, etc.)
 * without changing the business logic.
 */
interface NumberProviderInterface
{
    /**
     * Search for available numbers based on country and service.
     *
     * @param string $countryCode ISO country code (e.g., 'US', 'NG')
     * @param string $serviceSlug The type of service (e.g., 'whatsapp')
     * @return array A list of available numbers with their metadata.
     */
    public function searchNumbers(string $countryCode, string $serviceSlug = 'whatsapp'): array;

    /**
     * Purchase a specific number.
     *
     * @param string $phoneNumber The number to buy.
     * @param string $countryCode ISO country code.
     * @return array The result of the purchase transaction.
     */
    public function purchaseNumber(string $phoneNumber, string $countryCode): array;
}
