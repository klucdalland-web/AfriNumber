<?php

use App\Models\Platform;
use Database\Seeders\PlatformSeeder;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

beforeEach(function (): void {
    Schema::create('platforms', function (Blueprint $table): void {
        $table->id();
        $table->string('label', 200);
        $table->string('description', 500)->nullable();
        $table->boolean('actif')->default(true);
        $table->timestamps();
    });
});

afterEach(function (): void {
    Schema::dropIfExists('platforms');
});

test('platform seeder is idempotent and resolves api keys case-insensitively', function (): void {
    $this->seed(PlatformSeeder::class);
    $this->seed(PlatformSeeder::class);

    expect(Platform::query()->count())->toBe(3)
        ->and(Platform::findByKey('ios')?->label)->toBe('iOS')
        ->and(Platform::findByKey('iOS')?->label)->toBe('iOS')
        ->and(Platform::findByKey('ANDROID')?->label)->toBe('Android')
        ->and(Platform::findByKey('Web')?->label)->toBe('Web')
        ->and(Platform::findByKey('unknown'))->toBeNull()
        ->and(Platform::findByKey(''))->toBeNull();
});

test('ensure default platforms migration inserts missing rows', function (): void {
    $migration = require database_path('migrations/2026_09_25_223934_ensure_default_platforms_exist.php');
    $migration->up();
    $migration->up();

    expect(Platform::query()->count())->toBe(3)
        ->and(Platform::findByKey('ios'))->not->toBeNull()
        ->and(Platform::findByKey('android'))->not->toBeNull()
        ->and(Platform::findByKey('web'))->not->toBeNull();
});
