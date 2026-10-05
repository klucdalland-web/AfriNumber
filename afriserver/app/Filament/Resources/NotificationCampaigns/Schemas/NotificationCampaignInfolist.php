<?php

namespace App\Filament\Resources\NotificationCampaigns\Schemas;

use App\Models\NotificationCampaign;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class NotificationCampaignInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Message')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('typeNotification.label')
                            ->label('Type')
                            ->placeholder('-'),
                        TextEntry::make('channels')
                            ->label('Canaux')
                            ->badge()
                            ->formatStateUsing(fn ($state): string => match ($state) {
                                NotificationCampaign::CHANNEL_PUSH => 'Push',
                                NotificationCampaign::CHANNEL_EMAIL => 'E-mail',
                                default => (string) $state,
                            }),
                        TextEntry::make('title')
                            ->label('Titre')
                            ->columnSpanFull(),
                        TextEntry::make('body')
                            ->label('Corps')
                            ->columnSpanFull(),
                        TextEntry::make('email_subject')
                            ->label('Sujet e-mail')
                            ->placeholder('-')
                            ->columnSpanFull(),
                    ]),
                Section::make('Audience')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('audience_type')
                            ->label('Destinataires')
                            ->badge()
                            ->formatStateUsing(fn (string $state): string => match ($state) {
                                NotificationCampaign::AUDIENCE_ALL_USERS => 'Tous les utilisateurs actifs',
                                NotificationCampaign::AUDIENCE_SELECTED_USERS => 'Utilisateurs sélectionnés',
                                NotificationCampaign::AUDIENCE_ORGANISATION => 'Par organisation',
                                NotificationCampaign::AUDIENCE_PAYS => 'Par pays',
                                default => $state,
                            }),
                        TextEntry::make('organisation.label')
                            ->label('Organisation')
                            ->placeholder('-')
                            ->visible(fn (NotificationCampaign $record): bool => $record->audience_type === NotificationCampaign::AUDIENCE_ORGANISATION),
                        TextEntry::make('pays.label')
                            ->label('Pays')
                            ->placeholder('-')
                            ->visible(fn (NotificationCampaign $record): bool => $record->audience_type === NotificationCampaign::AUDIENCE_PAYS),
                        TextEntry::make('users_count')
                            ->label('Utilisateurs ciblés')
                            ->state(fn (NotificationCampaign $record): int => $record->users()->count())
                            ->visible(fn (NotificationCampaign $record): bool => $record->audience_type === NotificationCampaign::AUDIENCE_SELECTED_USERS),
                        TextEntry::make('device_scope')
                            ->label('Périmètre devices')
                            ->formatStateUsing(fn (?string $state): string => match ($state) {
                                NotificationCampaign::DEVICE_SCOPE_ALL => 'Tous',
                                NotificationCampaign::DEVICE_SCOPE_SELECTED => 'Sélectionnés',
                                default => (string) ($state ?? '-'),
                            }),
                        TextEntry::make('devices_count')
                            ->label('Devices ciblés')
                            ->state(fn (NotificationCampaign $record): int => $record->devices()->count())
                            ->visible(fn (NotificationCampaign $record): bool => $record->device_scope === NotificationCampaign::DEVICE_SCOPE_SELECTED),
                    ]),
                Section::make('Planification & statut')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('status')
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
                            }),
                        TextEntry::make('scheduled_at')
                            ->label('Planifiée le')
                            ->dateTime()
                            ->placeholder('-'),
                        TextEntry::make('sender.email')
                            ->label('Créée par')
                            ->placeholder('-'),
                        TextEntry::make('created_at')
                            ->label('Créée le')
                            ->dateTime(),
                    ]),
            ]);
    }
}
