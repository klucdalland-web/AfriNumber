<?php

namespace Database\Seeders;

use App\Models\TypeUser;
use Illuminate\Database\Seeder;

class TypeUserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            ['label' => 'Administrateur', 'code' => 'admin', 'description' => 'Administrateur système'],
            ['label' => 'Utilisateur', 'code' => 'user', 'description' => 'Utilisateur standard'],
            ['label' => 'Organisation', 'code' => 'organisation', 'description' => 'Compte organisation'],
        ];

        foreach ($types as $type) {
            TypeUser::query()->updateOrCreate(
                ['code' => $type['code']],
                $type + ['actif' => true],
            );
        }
    }
}
