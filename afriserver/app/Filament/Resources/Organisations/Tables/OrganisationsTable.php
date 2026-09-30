<?php

namespace App\Filament\Resources\Organisations\Tables;

use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class OrganisationsTable
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
                    ->limit(50)
                    ->toggleable(),
                IconColumn::make('actif')
                    ->label('Actif')
                    ->boolean()
                    ->sortable(),
                TextColumn::make('pays_count')
                    ->counts('pays')
                    ->label('Pays'),
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
