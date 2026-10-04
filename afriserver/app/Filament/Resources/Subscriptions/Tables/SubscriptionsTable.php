<?php

namespace App\Filament\Resources\Subscriptions\Tables;

use App\Models\Subscription;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class SubscriptionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('user.email')
                    ->label('Utilisateur')
                    ->description(fn (Subscription $record): ?string => $record->user?->name)
                    ->searchable()
                    ->sortable(),
                TextColumn::make('plan.label')
                    ->label('Plan')
                    ->description(fn (Subscription $record): ?string => $record->plan?->code)
                    ->searchable()
                    ->sortable(),
                TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        Subscription::STATUS_ACTIVE => 'success',
                        Subscription::STATUS_PENDING => 'warning',
                        Subscription::STATUS_EXPIRED => 'gray',
                        Subscription::STATUS_CANCELLED => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        Subscription::STATUS_ACTIVE => 'Actif',
                        Subscription::STATUS_PENDING => 'En attente',
                        Subscription::STATUS_EXPIRED => 'Expiré',
                        Subscription::STATUS_CANCELLED => 'Annulé',
                        default => $state,
                    })
                    ->sortable(),
                TextColumn::make('starts_at')
                    ->label('Début')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('ends_at')
                    ->label('Fin')
                    ->dateTime()
                    ->sortable(),
                IconColumn::make('auto_renew')
                    ->label('Auto')
                    ->boolean()
                    ->toggleable(),
                TextColumn::make('cancelled_at')
                    ->label('Annulé le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->label('Mis à jour')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('id', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        Subscription::STATUS_PENDING => 'En attente',
                        Subscription::STATUS_ACTIVE => 'Actif',
                        Subscription::STATUS_EXPIRED => 'Expiré',
                        Subscription::STATUS_CANCELLED => 'Annulé',
                    ]),
                SelectFilter::make('plan_id')
                    ->label('Plan')
                    ->relationship('plan', 'label'),
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
