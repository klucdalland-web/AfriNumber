<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;

class GeoLocationService
{
    public function getGeoFromIp(string $ip): array
    {
        try {
            $geo = Http::timeout(3)
                ->get("http://ip-api.com/json/{$ip}")
                ->json();

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
            return [
                'country' => null,
                'city' => null,
                'region' => null,
                'timezone' => null,
                'latitude' => null,
                'longitude' => null,
                'internet_provider' => null,
                'network_type' => null,
            ];
        }
    }
}