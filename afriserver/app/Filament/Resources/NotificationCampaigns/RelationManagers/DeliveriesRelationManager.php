<?php

namespace App\Filament\Resources\NotificationCampaigns\RelationManagers;

use App\Models\NotificationDelivery;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class DeliveriesRelationManager extends RelationManager
{
    protected static string $relationship = 'deliveries';

    protected static ?string $title = 'Historique des envois';

    protected static ?string $recordTitleAttribute = 'id';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')
                    ->label('#')
                    ->sortable(),
                TextColumn::make('user.email')
                    ->label('Utilisateur')
                    ->searchable()
                    ->description(fn (NotificationDelivery $record): ?string => $record->user?->name),
                TextColumn::make('channel')
                    ->label('Canal')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        NotificationDelivery::CHANNEL_PUSH => 'Push',
                        NotificationDelivery::CHANNEL_EMAIL => 'E-mail',
                        default => $state,
                    }),
                TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        NotificationDelivery::STATUS_SENT => 'success',
                        NotificationDelivery::STATUS_PENDING, NotificationDelivery::STATUS_PROCESSING => 'warning',
                        NotificationDelivery::STATUS_FAILED => 'danger',
                        NotificationDelivery::STATUS_NO_TOKEN, NotificationDelivery::STATUS_NO_EMAIL => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        NotificationDelivery::STATUS_PENDING => 'En attente',
                        NotificationDelivery::STATUS_PROCESSING => 'En cours',
                        NotificationDelivery::STATUS_SENT => 'Envoyé',
                        NotificationDelivery::STATUS_FAILED => 'Échoué',
                        NotificationDelivery::STATUS_NO_TOKEN => 'Sans token',
                        NotificationDelivery::STATUS_NO_EMAIL => 'Sans e-mail',
                        default => $state,
                    })
                    ->sortable(),
                TextColumn::make('error_message')
                    ->label('Erreur')
                    ->limit(40)
                    ->placeholder('-')
                    ->toggleable(),
                TextColumn::make('processed_at')
                    ->label('Traité le')
                    ->dateTime()
                    ->placeholder('-')
                    ->sortable(),
            ])
            ->defaultSort('id', 'desc')
            ->filters([
                SelectFilter::make('channel')
                    ->label('Canal')
                    ->options([
                        NotificationDelivery::CHANNEL_PUSH => 'Push',
                        NotificationDelivery::CHANNEL_EMAIL => 'E-mail',
                    ]),
                SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        NotificationDelivery::STATUS_PENDING => 'En attente',
                        NotificationDelivery::STATUS_PROCESSING => 'En cours',
                        NotificationDelivery::STATUS_SENT => 'Envoyé',
                        NotificationDelivery::STATUS_FAILED => 'Échoué',
                        NotificationDelivery::STATUS_NO_TOKEN => 'Sans token',
                        NotificationDelivery::STATUS_NO_EMAIL => 'Sans e-mail',
                    ]),
            ])
            ->headerActions([])
            ->recordActions([])
            ->toolbarActions([]);
    }
}
