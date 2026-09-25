<?php

use App\Services\GeoLocationService;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;

beforeEach(function (): void {
    Cache::flush();
});

test('ignore les IP privées et réservées', function (): void {
    Http::fake();

    $geo = app(GeoLocationService::class)->getGeoFromIp('127.0.0.1');

    expect($geo['country'])->toBeNull()
        ->and($geo['city'])->toBeNull();

    Http::assertNothingSent();
});

test('retourne empty si le provider échoue', function (): void {
    Http::fake([
        'ip-api.com/*' => Http::response([
            'status' => 'fail',
            'message' => 'reserved range',
        ]),
    ]);

    $geo = app(GeoLocationService::class)->getGeoFromIp('8.8.8.8');

    expect($geo['country'])->toBeNull();
});

test('mappe une réponse success et met en cache', function (): void {
    Http::fake([
        'ip-api.com/*' => Http::response([
            'status' => 'success',
            'country' => 'United States',
            'city' => 'Ashburn',
            'regionName' => 'Virginia',
            'timezone' => 'America/New_York',
            'lat' => 39.03,
            'lon' => -77.5,
            'isp' => 'Google LLC',
            'as' => 'AS15169 Google LLC',
            'query' => '8.8.8.8',
        ]),
    ]);

    $service = app(GeoLocationService::class);

    $first = $service->getGeoFromIp('8.8.8.8');
    $second = $service->getGeoFromIp('8.8.8.8');

    expect($first['country'])->toBe('United States')
        ->and($first['city'])->toBe('Ashburn')
        ->and($first['region'])->toBe('Virginia')
        ->and($first['internet_provider'])->toBe('Google LLC')
        ->and($second['country'])->toBe('United States');

    Http::assertSentCount(1);
});
