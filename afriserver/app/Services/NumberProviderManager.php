<?php

namespace App\Services;

use App\Contracts\NumberProviderInterface;
use App\Services\NumberProviders\MockNumberProvider;
use App\Services\NumberProviders\VerifiedCoreProvider;
use InvalidArgumentException;

class NumberProviderManager
{
    /**
     * Resolves the current provider based on the environment configuration.
     */
    public function getProvider(): NumberProviderInterface
    {
        $provider = config('services.numbers.default_provider', 'mock');

        return match ($provider) {
            'mock' => new MockNumberProvider(),
            'verifiedcore' => new VerifiedCoreProvider(),
            default => throw new InvalidArgumentException("Unsupported number provider: {$provider}"),
        };
    }
}
