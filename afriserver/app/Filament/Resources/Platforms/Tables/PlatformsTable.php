<?php

namespace App\Filament\Resources\Platforms\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class PlatformsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('label')
                    ->label('Libellé')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('description')
                    ->label('Description')
                    ->limit(60)
                    ->searchable()
                    ->toggleable(),
                IconColumn::make('actif')
                    ->label('Actif')
                    ->boolean()
                    ->sortable(),
                TextColumn::make('devices_count')
                    ->counts('devices')
                    ->label('Devices'),
                TextColumn::make('updated_at')
                    ->label('Mis à jour')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('label')
            ->filters([
                TernaryFilter::make('actif')
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
