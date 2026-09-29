<?php

namespace App\Filament\Commands;

use Filament\Commands\MakeUserCommand as BaseMakeUserCommand;
use Symfony\Component\Console\Input\InputOption;

use function Laravel\Prompts\text;

class MakeUserCommand extends BaseMakeUserCommand
{
    /**
     * @return array<InputOption>
     */
    protected function getOptions(): array
    {
        return [
            ...parent::getOptions(),
            new InputOption(
                name: 'first-name',
                shortcut: null,
                mode: InputOption::VALUE_REQUIRED,
                description: 'The first name of the user',
            ),
            new InputOption(
                name: 'phone-number',
                shortcut: null,
                mode: InputOption::VALUE_REQUIRED,
                description: 'A unique phone number for the user',
            ),
        ];
    }

    /**
     * @return array{name: string, email: string, password: string, first_name: string, phone_number: string}
     */
    protected function getUserData(): array
    {
        return [
            ...parent::getUserData(),

            'first_name' => $this->options['first-name'] ?? text(
                label: 'First name',
                required: true,
            ),

            'phone_number' => $this->options['phone-number'] ?? text(
                label: 'Phone number',
                required: true,
                validate: fn (string $phone): ?string => match (true) {
                    static::getUserModel()::query()->where('phone_number', $phone)->exists() => 'A user with this phone number already exists',
                    default => null,
                },
            ),
        ];
    }
}
