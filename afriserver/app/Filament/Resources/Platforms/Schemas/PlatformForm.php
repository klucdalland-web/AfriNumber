<?php

namespace App\Filament\Resources\Platforms\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class PlatformForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Plateforme')
                    ->schema([
                        TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->maxLength(200)
                            ->unique(ignoreRecord: true)
                            ->helperText('Clé utilisée par l\'API mobile (ex. Android, iOS, Web). La résolution est insensible à la casse.'),
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
