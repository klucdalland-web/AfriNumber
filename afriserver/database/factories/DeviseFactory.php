<?php

namespace Database\Factories;

use App\Models\Devise;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Devise>
 */
class DeviseFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'code' => strtoupper(fake()->unique()->lexify('???')),
            'label' => fake()->currencyCode().' Currency',
            'symbole' => fake()->randomElement(['$', '€', 'FCFA', '£']),
            'actif' => true,
        ];
    }
}
