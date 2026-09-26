<?php

use Database\Seeders\DatabaseSeeder;
use Database\Seeders\RequiredDataSeeder;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

test('entrypoint seeds only RequiredDataSeeder', function (): void {
    $entrypoint = File::get(base_path('entrypoint.sh'));

    expect($entrypoint)->toContain('db:seed --class=RequiredDataSeeder')
        ->and($entrypoint)->not->toMatch('/db:seed --class=(?!RequiredDataSeeder)\w+/');
});

test('every referential seeder is registered in RequiredDataSeeder', function (): void {
    $excluded = [
        DatabaseSeeder::class,
        RequiredDataSeeder::class,
    ];

    /** Seeders de démo / locaux uniquement — pas déployés via RequiredDataSeeder. */
    $developmentOnly = [
        // Exemple futur : DemoDataSeeder::class,
    ];

    $discovered = collect(File::files(database_path('seeders')))
        ->map(fn ($file) => 'Database\\Seeders\\'.$file->getFilenameWithoutExtension())
        ->filter(fn (string $class) => is_subclass_of($class, Seeder::class))
        ->reject(fn (string $class) => in_array($class, $excluded, true))
        ->reject(fn (string $class) => in_array($class, $developmentOnly, true))
        ->sort()
        ->values()
        ->all();

    $registered = collect(RequiredDataSeeder::seeders())->sort()->values()->all();

    expect($registered)->toBe($discovered);
});

