<?php

namespace Database\Seeders;

use App\Models\Platform;
use Illuminate\Database\Seeder;

class PlatformSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $platforms = [
            ['label' => 'Android', 'description' => 'Plateforme Android'],
            ['label' => 'Web', 'description' => 'Plateforme Web'],
            ['label' => 'iOS', 'description' => 'Plateforme iOS'],
        ];

        foreach ($platforms as $platform) {
            Platform::query()->updateOrCreate(
                ['label' => $platform['label']],
                $platform + ['actif' => true],
            );
        }
    }
}
