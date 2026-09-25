<?php

namespace Database\Seeders;

use App\Models\Organisation;
use App\Models\Pays;
use Illuminate\Database\Seeder;

class OrganisationSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $organisations = [
            [
                'label' => 'UEMOA',
                'description' => 'Union Économique et Monétaire Ouest-Africaine',
                'codes' => ['BJ', 'BF', 'CI', 'ML', 'NE', 'SN', 'TG'],
            ],
            [
                'label' => 'CEMAC',
                'description' => 'Communauté Économique et Monétaire de l\'Afrique Centrale',
                'codes' => ['CM', 'GA'],
            ],
            [
                'label' => 'Autres',
                'description' => 'Pays hors blocs UEMOA / CEMAC',
                'codes' => ['GH', 'GN', 'NG'],
            ],
        ];

        foreach ($organisations as $data) {
            $organisation = Organisation::query()->updateOrCreate(
                ['label' => $data['label']],
                [
                    'description' => $data['description'],
                    'actif' => true,
                ],
            );

            Pays::query()
                ->whereIn('code', $data['codes'])
                ->update(['organisation_id' => $organisation->id]);
        }
    }
}
