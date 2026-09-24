<?php

namespace Database\Seeders;

use App\Models\Continent;
use Illuminate\Database\Seeder;

class ContinentSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $continents = [
            ['label' => 'Afrique', 'code' => 'AF', 'description' => 'Continent africain'],
            ['label' => 'Amérique', 'code' => 'AM', 'description' => 'Continent américain'],
            ['label' => 'Antarctique', 'code' => 'AN', 'description' => 'Continent antarctique'],
            ['label' => 'Asie', 'code' => 'AS', 'description' => 'Continent asiatique'],
            ['label' => 'Europe', 'code' => 'EU', 'description' => 'Continent européen'],
            ['label' => 'Océanie', 'code' => 'OC', 'description' => 'Continent océanien'],
        ];

        foreach ($continents as $continent) {
            Continent::query()->updateOrCreate(
                ['code' => $continent['code']],
                $continent + ['actif' => true],
            );
        }
    }
}
