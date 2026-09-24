<?php

namespace Database\Factories;

use App\Models\Continent;
use App\Models\Pays;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Pays>
 */
class PaysFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'continent_id' => Continent::factory(),
            'organisation_id' => null,
            'label' => fake()->unique()->country(),
            'code' => fake()->unique()->countryCode(),
            'indicatif' => '+'.fake()->numberBetween(1, 999),
            'description' => fake()->optional()->sentence(),
            'actif' => true,
        ];
    }
}
