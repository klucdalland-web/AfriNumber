<?php

namespace Database\Factories;

use App\Models\FraisTransaction;
use App\Models\TypeTransaction;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<FraisTransaction>
 */
class FraisTransactionFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'type_transaction_id' => function (): int {
                return TypeTransaction::query()->create([
                    'code' => 'test_'.Str::lower(Str::random(8)),
                    'label' => fake()->words(2, true),
                    'description' => null,
                    'actif' => true,
                    'sort_order' => 0,
                ])->id;
            },
            'pays_id' => null,
            'montant_fixe' => '0.00000000',
            'taux_pourcentage' => '1.0000',
            'montant_min' => null,
            'montant_max' => null,
            'statut' => FraisTransaction::STATUT_ACTIF,
        ];
    }

    public function inactif(): static
    {
        return $this->state(fn (): array => [
            'statut' => FraisTransaction::STATUT_INACTIF,
        ]);
    }

    public function pourPays(int $paysId): static
    {
        return $this->state(fn (): array => [
            'pays_id' => $paysId,
        ]);
    }
}
