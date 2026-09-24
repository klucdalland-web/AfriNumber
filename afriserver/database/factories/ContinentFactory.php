<?php

namespace Database\Factories;

use App\Models\Continent;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Continent>
 */
class ContinentFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'label' => fake()->unique()->word(),
            'code' => fake()->unique()->lexify('???'),
            'description' => fake()->optional()->sentence(),
            'actif' => true,
        ];
    }
}
