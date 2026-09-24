<?php

namespace Database\Factories;

use App\Models\TypeUser;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<TypeUser>
 */
class TypeUserFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'label' => fake()->unique()->jobTitle(),
            'code' => fake()->unique()->lexify('???'),
            'description' => fake()->optional()->sentence(),
            'actif' => true,
        ];
    }
}
