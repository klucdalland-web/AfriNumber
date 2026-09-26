<?php

namespace Database\Seeders;

use App\Models\TypePieceIdentite;
use Illuminate\Database\Seeder;

class TypePieceIdentiteSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $types = [
            [
                'label' => 'Carte Nationale d\'Identité',
                'description' => 'CNI délivrée par l\'État',
            ],
            [
                'label' => 'Passeport',
                'description' => 'Passeport biométrique ou ordinaire',
            ],
            [
                'label' => 'Permis de conduire',
                'description' => 'Permis de conduire valide',
            ],
            [
                'label' => 'Carte de séjour',
                'description' => 'Titre de séjour ou carte de résident',
            ],
            [
                'label' => 'Carte d\'électeur',
                'description' => 'Carte d\'électeur officielle',
            ],
            [
                'label' => 'Acte de naissance',
                'description' => 'Extrait ou copie d\'acte de naissance',
            ],
        ];

        foreach ($types as $type) {
            TypePieceIdentite::query()->updateOrCreate(
                ['label' => $type['label']],
                $type,
            );
        }
    }
}
