<?php

namespace Database\Factories;

use App\Models\Compte;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Compte>
 */
class CompteFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'numero_compte' => 'AFN'.fake()->unique()->numerify('############'),
            'solde' => 0,
            'statut' => Compte::STATUT_ACTIF,
            'user_id' => User::factory(),
        ];
    }
}
