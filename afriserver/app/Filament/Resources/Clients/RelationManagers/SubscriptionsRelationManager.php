<?php

namespace App\Filament\Resources\Clients\RelationManagers;

use App\Models\Subscription;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class SubscriptionsRelationManager extends RelationManager
{
    protected static string $relationship = 'subscriptions';

    protected static ?string $title = 'Abonnements';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')
                    ->label('#')
                    ->sortable(),
                TextColumn::make('plan.label')
                    ->label('Plan')
                    ->placeholder('-'),
                TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        Subscription::STATUS_ACTIVE => 'success',
                        Subscription::STATUS_CANCELLED => 'danger',
                        Subscription::STATUS_EXPIRED => 'gray',
                        default => 'warning',
                    }),
                TextColumn::make('starts_at')
                    ->label('Début')
                    ->dateTime()
                    ->placeholder('-'),
                TextColumn::make('ends_at')
                    ->label('Fin')
                    ->dateTime()
                    ->placeholder('-'),
                TextColumn::make('created_at')
                    ->label('Créé le')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('id', 'desc')
            ->headerActions([])
            ->recordActions([])
            ->toolbarActions([]);
    }
}
