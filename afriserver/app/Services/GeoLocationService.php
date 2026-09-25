<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class GeoLocationService
{
    private const CACHE_TTL_SECONDS = 86400; // 24h

    private const EMPTY = [
        'country' => null,
        'city' => null,
        'region' => null,
        'timezone' => null,
        'latitude' => null,
        'longitude' => null,
        'internet_provider' => null,
        'network_type' => null,
    ];

    public function getGeoFromIp(?string $ip): array
    {
        $ip = $this->normalizeIp($ip);

        if ($ip === null || $this->isNonPublicIp($ip)) {
            return self::EMPTY;
        }

        $cacheKey = 'geo:ip:'.md5($ip);

        return Cache::remember($cacheKey, self::CACHE_TTL_SECONDS, function () use ($ip): array {
            return $this->fetchFromProvider($ip);
        });
    }

    /**
     * @return array<string, mixed>
     */
    private function fetchFromProvider(string $ip): array
    {
        try {
            $response = Http::timeout(3)
                ->acceptJson()
                ->get("http://ip-api.com/json/{$ip}", [
                    'fields' => 'status,message,country,city,regionName,timezone,lat,lon,isp,as,query',
                ]);

            if (! $response->successful()) {
                Log::warning('GeoLocation: HTTP error', [
                    'ip' => $ip,
                    'status' => $response->status(),
                ]);

                return self::EMPTY;
            }

            $geo = $response->json();

            if (! is_array($geo) || ($geo['status'] ?? null) !== 'success') {
                Log::debug('GeoLocation: lookup failed', [
                    'ip' => $ip,
                    'message' => $geo['message'] ?? 'unknown',
                ]);

                return self::EMPTY;
            }

            return [
                'country' => $geo['country'] ?? null,
                'city' => $geo['city'] ?? null,
                'region' => $geo['regionName'] ?? null,
                'timezone' => $geo['timezone'] ?? null,
                'latitude' => $geo['lat'] ?? null,
                'longitude' => $geo['lon'] ?? null,
                'internet_provider' => $geo['isp'] ?? null,
                'network_type' => $geo['as'] ?? null,
            ];
        } catch (\Throwable $e) {
            Log::warning('GeoLocation: exception', [
                'ip' => $ip,
                'error' => $e->getMessage(),
            ]);

            return self::EMPTY;
        }
    }

    private function normalizeIp(?string $ip): ?string
    {
        if ($ip === null) {
            return null;
        }

        $ip = trim($ip);

        if ($ip === '' || strcasecmp($ip, 'unknown') === 0) {
            return null;
        }

        // X-Forwarded-For peut contenir plusieurs IPs
        if (str_contains($ip, ',')) {
            $ip = trim(explode(',', $ip)[0]);
        }

        return filter_var($ip, FILTER_VALIDATE_IP) ?: null;
    }

    private function isNonPublicIp(string $ip): bool
    {
        // Privée, réservée, loopback, link-local, etc.
        return filter_var(
            $ip,
            FILTER_VALIDATE_IP,
            FILTER_FLAG_NO_PRIV_RANGE | FILTER_FLAG_NO_RES_RANGE
        ) === false;
    }
}
