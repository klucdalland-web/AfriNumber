<?php

namespace App\Filament\Resources\Continents\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ContinentForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Continent')
                    ->schema([
                        TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->maxLength(200),
                        TextInput::make('code')
                            ->label('Code')
                            ->required()
                            ->maxLength(10)
                            ->unique(ignoreRecord: true)
                            ->helperText('Code ISO court (ex. AF).'),
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
