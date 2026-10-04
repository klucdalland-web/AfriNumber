<?php

namespace App\Filament\Resources\Plans\Schemas;

use App\Models\Service;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class PlanForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Plan')
                    ->columns(2)
                    ->schema([
                        TextInput::make('code')
                            ->label('Code')
                            ->required()
                            ->maxLength(50)
                            ->unique(ignoreRecord: true)
                            ->helperText('Identifiant technique (ex. basic, pro).'),
                        TextInput::make('label')
                            ->label('Libellé')
                            ->required()
                            ->maxLength(200),
                        Textarea::make('description')
                            ->label('Description')
                            ->rows(3)
                            ->columnSpanFull(),
                        TextInput::make('price')
                            ->label('Prix')
                            ->required()
                            ->numeric()
                            ->minValue(0),
                        TextInput::make('currency')
                            ->label('Devise')
                            ->required()
                            ->maxLength(3)
                            ->default('XOF'),
                        TextInput::make('duration_days')
                            ->label('Durée (jours)')
                            ->required()
                            ->numeric()
                            ->minValue(1)
                            ->default(30),
                        TextInput::make('max_numbers')
                            ->label('Max numéros')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->default(1),
                        TextInput::make('sort_order')
                            ->label('Ordre')
                            ->required()
                            ->numeric()
                            ->default(0),
                        Toggle::make('is_active')
                            ->label('Actif')
                            ->default(true)
                            ->required(),
                    ]),
                Section::make('Services inclus')
                    ->description('Associez les services du plan et leurs quotas (vide = illimité / feature seule).')
                    ->schema([
                        Repeater::make('serviceAttachments')
                            ->label('Services')
                            ->schema([
                                Select::make('service_id')
                                    ->label('Service')
                                    ->options(fn (): array => Service::query()
                                        ->orderBy('label')
                                        ->pluck('label', 'id')
                                        ->all())
                                    ->searchable()
                                    ->required()
                                    ->distinct()
                                    ->disableOptionsWhenSelectedInSiblingRepeaterItems(),
                                TextInput::make('quota')
                                    ->label('Quota')
                                    ->numeric()
                                    ->minValue(0)
                                    ->nullable()
                                    ->helperText('Laisser vide si pas de limite.'),
                            ])
                            ->columns(2)
                            ->defaultItems(0)
                            ->reorderable(false)
                            ->addActionLabel('Ajouter un service')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
