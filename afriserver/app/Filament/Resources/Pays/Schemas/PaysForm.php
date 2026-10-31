<?php

namespace App\Filament\Resources\Pays\Schemas;

use App\Models\Devise;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class PaysForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Pays')
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
                            ->helperText('Code ISO (ex. BJ).'),
                        TextInput::make('indicatif')
                            ->label('Indicatif')
                            ->maxLength(10)
                            ->placeholder('+229'),
                        TextInput::make('timezone')
                            ->label('Fuseau horaire')
                            ->maxLength(64)
                            ->placeholder('Africa/Abidjan')
                            ->helperText('Identifiant IANA (ex. Indian/Antananarivo). Utilisé pour dater les e-mails.'),
                        Select::make('continent_id')
                            ->label('Continent')
                            ->relationship('continent', 'label')
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('organisation_id')
                            ->label('Organisation')
                            ->relationship('organisation', 'label')
                            ->searchable()
                            ->preload()
                            ->nullable(),
                        Select::make('devise_id')
                            ->label('Devise')
                            ->relationship('devise', 'label')
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => "{$record->code} — {$record->label} ({$record->symbole})"
                            )
                            ->searchable()
                            ->preload()
                            ->nullable()
                            ->live()
                            ->afterStateUpdated(function ($state, callable $set): void {
                                if (! $state) {
                                    return;
                                }

                                $devise = Devise::query()->find($state);
                                if ($devise) {
                                    $set('currency_code', $devise->code);
                                    $set('currency_symbol', $devise->symbole);
                                }
                            }),
                        TextInput::make('currency_code')
                            ->label('Code devise')
                            ->maxLength(3)
                            ->placeholder('XAF'),
                        TextInput::make('currency_symbol')
                            ->label('Symbole')
                            ->maxLength(10)
                            ->placeholder('FCFA'),
                        TextInput::make('exchange_rate')
                            ->label('Taux de conversion')
                            ->numeric()
                            ->default(1)
                            ->helperText('Taux local → USD (ex. 600 pour XAF).'),
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
