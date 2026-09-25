<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        $now = now();

        $platforms = [
            ['label' => 'Android', 'description' => 'Plateforme Android'],
            ['label' => 'Web', 'description' => 'Plateforme Web'],
            ['label' => 'iOS', 'description' => 'Plateforme iOS'],
        ];

        foreach ($platforms as $platform) {
            $exists = DB::table('platforms')
                ->whereRaw('LOWER(label) = ?', [strtolower($platform['label'])])
                ->exists();

            if ($exists) {
                continue;
            }

            DB::table('platforms')->insert([
                'label' => $platform['label'],
                'description' => $platform['description'],
                'actif' => true,
                'created_at' => $now,
                'updated_at' => $now,
            ]);
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Les plateformes peuvent déjà être référencées par des devices : pas de suppression.
    }
};
