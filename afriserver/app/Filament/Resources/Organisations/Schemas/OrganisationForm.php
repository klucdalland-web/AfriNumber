<?php

namespace App\Filament\Resources\Organisations\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class OrganisationForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Organisation')
                    ->schema([
                        TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->maxLength(200),
                        TextInput::make('description')
                            ->label('Description')
                            ->maxLength(500),
                        Toggle::make('actif')
                            ->label('Actif')
                            ->default(true)
                            ->required(),
                    ]),
            ]);
    }
}
