<?php

use App\Support\GeoMapUrl;

test('geo map url builds google maps link from coordinates', function (): void {
    $location = [
        'city' => 'Cotonou',
        'region' => 'Littoral',
        'country' => 'Benin',
        'latitude' => 6.3703,
        'longitude' => 2.3912,
    ];

    expect(GeoMapUrl::label($location))->toBe('Cotonou, Littoral, Benin')
        ->and(GeoMapUrl::fromLocation($location))->toBe('https://www.google.com/maps?q=6.3703,2.3912')
        ->and(GeoMapUrl::fromLocation(['city' => 'Cotonou']))->toBeNull()
        ->and(GeoMapUrl::openStreetMapEmbed(6.3703, 2.3912))->toContain('openstreetmap.org/export/embed.html');
});
