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
        $organisation = Organisation::query()->updateOrCreate(
            ['label' => 'AfriNumber'],
            [
                'description' => 'Marchés d\'expansion AfriNumber',
                'actif' => true,
            ],
        );

        Pays::query()->update(['organisation_id' => null]);

        Pays::query()
            ->whereIn('code', ['MG', 'CG'])
            ->update(['organisation_id' => $organisation->id]);

        Organisation::query()
            ->whereIn('label', ['UEMOA', 'CEMAC', 'Autres'])
            ->update(['actif' => false]);
    }
}
