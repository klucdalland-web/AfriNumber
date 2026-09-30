<?php

namespace Database\Factories;

use App\Models\TypeUser;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'pays_id' => null,
            'type_user_id' => null,
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'phone_number' => fake()->unique()->e164PhoneNumber(),
            'statut' => 'actif',
            'first_name' => fake()->firstName(), // <-- Ajoutez cette ligne

            'status_valide' => 'non_valide',
            'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'remember_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }

    public function admin(): static
    {
        return $this->state(fn (array $attributes) => [
            'type_user_id' => TypeUser::query()->updateOrCreate(
                ['code' => 'admin'],
                [
                    'label' => 'Administrateur',
                    'description' => 'Administrateur système',
                    'actif' => true,
                ],
            )->id,
        ]);
    }

    public function ofType(string $code): static
    {
        return $this->state(fn (array $attributes) => [
            'type_user_id' => TypeUser::query()->where('code', $code)->value('id')
                ?? TypeUser::factory()->create(['code' => $code])->id,
        ]);
    }

    public function withRole(string $role): static
    {
        return $this->afterCreating(function (User $user) use ($role): void {
            $user->assignRole($role);
        });
    }
}
