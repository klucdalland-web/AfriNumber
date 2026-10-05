<?php

namespace App\Filament\Resources\Pays\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class PaysTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('label')
                    ->label('Libellé')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('code')
                    ->label('Code')
                    ->badge()
                    ->searchable()
                    ->sortable(),
                TextColumn::make('indicatif')
                    ->label('Indicatif')
                    ->toggleable(),
                TextColumn::make('timezone')
                    ->label('Fuseau')
                    ->placeholder('—')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('continent.label')
                    ->label('Continent')
                    ->sortable()
                    ->searchable(),
                TextColumn::make('organisation.label')
                    ->label('Organisation')
                    ->placeholder('—')
                    ->toggleable(),
                IconColumn::make('actif')
                    ->label('Actif')
                    ->boolean()
                    ->sortable(),
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
                SelectFilter::make('continent_id')
                    ->label('Continent')
                    ->relationship('continent', 'label'),
                SelectFilter::make('organisation_id')
                    ->label('Organisation')
                    ->relationship('organisation', 'label'),
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
