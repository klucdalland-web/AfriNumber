<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

/**
 * Référentiels idempotents requis en production.
 *
 * Tout nouveau seeder de données métier indispensables (types, plateformes,
 * pays, etc.) DOIT être ajouté ici — pas dans entrypoint.sh.
 * Le déploiement n'appelle que cette classe.
 */
class RequiredDataSeeder extends Seeder
{
    /**
     * @return list<class-string<Seeder>>
     */
    public static function seeders(): array
    {
        return [
            TypeUserSeeder::class,
            ContinentSeeder::class,
            PaysSeeder::class,
            OrganisationSeeder::class,
            PlatformSeeder::class,
            TypePieceIdentiteSeeder::class,
        ];
    }

    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $this->call(self::seeders());
    }
}
