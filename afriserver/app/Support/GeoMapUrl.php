<?php

namespace App\Support;

final class GeoMapUrl
{
    /**
     * @param  array<string, mixed>|null  $location
     */
    public static function fromLocation(?array $location): ?string
    {
        if ($location === null) {
            return null;
        }

        $latitude = self::coordinate($location['latitude'] ?? null);
        $longitude = self::coordinate($location['longitude'] ?? null);

        if ($latitude === null || $longitude === null) {
            return null;
        }

        return self::googleMaps($latitude, $longitude);
    }

    public static function googleMaps(float $latitude, float $longitude): string
    {
        return sprintf(
            'https://www.google.com/maps?q=%s,%s',
            self::formatCoordinate($latitude),
            self::formatCoordinate($longitude),
        );
    }

    public static function openStreetMapEmbed(float $latitude, float $longitude, float $delta = 0.05): string
    {
        $minLon = $longitude - $delta;
        $minLat = $latitude - $delta;
        $maxLon = $longitude + $delta;
        $maxLat = $latitude + $delta;

        return sprintf(
            'https://www.openstreetmap.org/export/embed.html?bbox=%s%%2C%s%%2C%s%%2C%s&layer=mapnik&marker=%s%%2C%s',
            self::formatCoordinate($minLon),
            self::formatCoordinate($minLat),
            self::formatCoordinate($maxLon),
            self::formatCoordinate($maxLat),
            self::formatCoordinate($latitude),
            self::formatCoordinate($longitude),
        );
    }

    /**
     * @param  array<string, mixed>|null  $location
     */
    public static function label(?array $location): ?string
    {
        if ($location === null) {
            return null;
        }

        $parts = array_values(array_filter([
            $location['city'] ?? null,
            $location['region'] ?? null,
            $location['country'] ?? null,
        ], fn (mixed $value): bool => is_string($value) && trim($value) !== ''));

        if ($parts === []) {
            return null;
        }

        return implode(', ', $parts);
    }

    private static function coordinate(mixed $value): ?float
    {
        if ($value === null || $value === '') {
            return null;
        }

        if (! is_numeric($value)) {
            return null;
        }

        return (float) $value;
    }

    private static function formatCoordinate(float $value): string
    {
        return rtrim(rtrim(number_format($value, 8, '.', ''), '0'), '.') ?: '0';
    }
}
