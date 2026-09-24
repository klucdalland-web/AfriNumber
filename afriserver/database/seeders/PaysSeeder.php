<?php

namespace Database\Seeders;

use App\Models\Continent;
use App\Models\Pays;
use Illuminate\Database\Seeder;

class PaysSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $afriqueId = Continent::query()->where('code', 'AF')->value('id');

        if ($afriqueId === null) {
            return;
        }

        $pays = [
            ['label' => 'Bénin', 'code' => 'BJ', 'indicatif' => '+229'],
            ['label' => 'Burkina Faso', 'code' => 'BF', 'indicatif' => '+226'],
            ['label' => 'Cameroun', 'code' => 'CM', 'indicatif' => '+237'],
            ['label' => 'Côte d\'Ivoire', 'code' => 'CI', 'indicatif' => '+225'],
            ['label' => 'Gabon', 'code' => 'GA', 'indicatif' => '+241'],
            ['label' => 'Ghana', 'code' => 'GH', 'indicatif' => '+233'],
            ['label' => 'Guinée', 'code' => 'GN', 'indicatif' => '+224'],
            ['label' => 'Mali', 'code' => 'ML', 'indicatif' => '+223'],
            ['label' => 'Niger', 'code' => 'NE', 'indicatif' => '+227'],
            ['label' => 'Nigéria', 'code' => 'NG', 'indicatif' => '+234'],
            ['label' => 'Sénégal', 'code' => 'SN', 'indicatif' => '+221'],
            ['label' => 'Togo', 'code' => 'TG', 'indicatif' => '+228'],
        ];

        foreach ($pays as $paysData) {
            Pays::query()->updateOrCreate(
                ['code' => $paysData['code']],
                $paysData + [
                    'continent_id' => $afriqueId,
                    'actif' => true,
                ],
            );
        }
    }
}
