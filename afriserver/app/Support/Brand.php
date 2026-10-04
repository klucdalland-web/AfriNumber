<?php

namespace App\Support;

class Brand
{
    public static function name(): string
    {
        return (string) config('brand.name', config('app.name', 'AfriNumber'));
    }

    /**
     * URL absolue du logo (white = fond sombre, black = fond clair).
     *
     * @param  'white'|'black'  $variant
     */
    public static function logoUrl(string $variant = 'black'): string
    {
        $path = (string) config("brand.logos.{$variant}", "logo-afrika-{$variant}.png");

        return asset($path);
    }

    public static function logoWhiteUrl(): string
    {
        return self::logoUrl('white');
    }

    public static function logoBlackUrl(): string
    {
        return self::logoUrl('black');
    }

    /**
     * @return array<string, string>
     */
    public static function colors(): array
    {
        /** @var array<string, string> $colors */
        $colors = config('brand.colors', []);

        return $colors;
    }

    public static function color(string $key, string $fallback = '#1C1A17'): string
    {
        return (string) (self::colors()[$key] ?? $fallback);
    }
}
