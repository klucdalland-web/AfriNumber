<?php

namespace App\Filament\Resources\Plans\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class PlansTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('sort_order')
                    ->label('#')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('code')
                    ->label('Code')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('label')
                    ->label('Libellé')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('price')
                    ->label('Prix')
                    ->formatStateUsing(
                        fn ($state, $record): string => number_format((float) $state, 0, ',', ' ').' '.$record->currency
                    )
                    ->sortable(),
                TextColumn::make('duration_days')
                    ->label('Durée')
                    ->suffix(' j')
                    ->sortable(),
                TextColumn::make('max_numbers')
                    ->label('Max n°')
                    ->sortable(),
                TextColumn::make('services_count')
                    ->counts('services')
                    ->label('Services'),
                IconColumn::make('is_active')
                    ->label('Actif')
                    ->boolean()
                    ->sortable(),
                TextColumn::make('updated_at')
                    ->label('Mis à jour')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('sort_order')
            ->filters([
                TernaryFilter::make('is_active')
                    ->label('Actif'),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
