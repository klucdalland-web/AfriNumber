<?php

namespace App\Filament\Resources\NotificationCampaigns\Tables;

use App\Models\NotificationCampaign;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class NotificationCampaignsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('id')
                    ->label('#')
                    ->sortable(),
                TextColumn::make('title')
                    ->label('Titre')
                    ->searchable()
                    ->limit(40)
                    ->tooltip(fn (NotificationCampaign $record): string => $record->title),
                TextColumn::make('typeNotification.label')
                    ->label('Type')
                    ->placeholder('-')
                    ->toggleable(),
                TextColumn::make('channels')
                    ->label('Canaux')
                    ->badge()
                    ->formatStateUsing(fn ($state): string => is_array($state)
                        ? implode(', ', $state)
                        : (string) $state),
                TextColumn::make('audience_type')
                    ->label('Audience')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        NotificationCampaign::AUDIENCE_ALL_USERS => 'Tous',
                        NotificationCampaign::AUDIENCE_SELECTED_USERS => 'Sélection',
                        NotificationCampaign::AUDIENCE_ORGANISATION => 'Organisation',
                        NotificationCampaign::AUDIENCE_PAYS => 'Pays',
                        default => $state,
                    }),
                TextColumn::make('status')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        NotificationCampaign::STATUS_SCHEDULED => 'info',
                        NotificationCampaign::STATUS_QUEUED => 'warning',
                        NotificationCampaign::STATUS_PROCESSING => 'warning',
                        NotificationCampaign::STATUS_COMPLETED => 'success',
                        NotificationCampaign::STATUS_CANCELLED => 'gray',
                        NotificationCampaign::STATUS_FAILED => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        NotificationCampaign::STATUS_SCHEDULED => 'Planifiée',
                        NotificationCampaign::STATUS_QUEUED => 'En file',
                        NotificationCampaign::STATUS_PROCESSING => 'En cours',
                        NotificationCampaign::STATUS_COMPLETED => 'Terminée',
                        NotificationCampaign::STATUS_CANCELLED => 'Annulée',
                        NotificationCampaign::STATUS_FAILED => 'Échouée',
                        default => $state,
                    })
                    ->sortable(),
                TextColumn::make('scheduled_at')
                    ->label('Planifiée le')
                    ->dateTime()
                    ->placeholder('-')
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('sender.email')
                    ->label('Créée par')
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('id', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        NotificationCampaign::STATUS_SCHEDULED => 'Planifiée',
                        NotificationCampaign::STATUS_QUEUED => 'En file',
                        NotificationCampaign::STATUS_PROCESSING => 'En cours',
                        NotificationCampaign::STATUS_COMPLETED => 'Terminée',
                        NotificationCampaign::STATUS_CANCELLED => 'Annulée',
                        NotificationCampaign::STATUS_FAILED => 'Échouée',
                    ]),
                SelectFilter::make('audience_type')
                    ->label('Audience')
                    ->options([
                        NotificationCampaign::AUDIENCE_ALL_USERS => 'Tous',
                        NotificationCampaign::AUDIENCE_SELECTED_USERS => 'Sélection',
                        NotificationCampaign::AUDIENCE_ORGANISATION => 'Organisation',
                        NotificationCampaign::AUDIENCE_PAYS => 'Pays',
                    ]),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make()
                    ->visible(fn (NotificationCampaign $record): bool => $record->isEditable()),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
