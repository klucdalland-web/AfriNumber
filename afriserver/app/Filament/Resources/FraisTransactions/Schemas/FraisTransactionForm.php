<?php

namespace App\Filament\Resources\FraisTransactions\Schemas;

use App\Models\FraisTransaction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class FraisTransactionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Règle de frais')
                    ->columns(2)
                    ->schema([
                        Select::make('type_transaction_id')
                            ->label('Type de transaction')
                            ->relationship('typeTransaction', 'label')
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => "{$record->code} — {$record->label}"
                            )
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('pays_id')
                            ->label('Pays')
                            ->relationship('pays', 'label')
                            ->searchable()
                            ->preload()
                            ->nullable()
                            ->placeholder('Tous les pays (règle par défaut)')
                            ->helperText('Laisser vide pour une règle par défaut applicable à tous les pays sans règle propre.'),
                        TextInput::make('montant_fixe')
                            ->label('Montant fixe (USD)')
                            ->numeric()
                            ->required()
                            ->default('0')
                            ->minValue(0)
                            ->step('0.00000001'),
                        TextInput::make('taux_pourcentage')
                            ->label('Taux (%)')
                            ->numeric()
                            ->required()
                            ->default('0')
                            ->minValue(0)
                            ->maxValue(100)
                            ->step('0.0001'),
                        TextInput::make('montant_min')
                            ->label('Montant min (USD)')
                            ->numeric()
                            ->nullable()
                            ->minValue(0)
                            ->step('0.00000001'),
                        TextInput::make('montant_max')
                            ->label('Montant max (USD)')
                            ->numeric()
                            ->nullable()
                            ->minValue(0)
                            ->step('0.00000001')
                            ->gte('montant_min'),
                        Select::make('statut')
                            ->label('Statut')
                            ->options([
                                FraisTransaction::STATUT_ACTIF => 'Actif',
                                FraisTransaction::STATUT_INACTIF => 'Inactif',
                            ])
                            ->default(FraisTransaction::STATUT_ACTIF)
                            ->required(),
                    ]),
            ]);
    }
}
