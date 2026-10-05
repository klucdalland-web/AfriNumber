<?php

namespace App\Filament\Resources\NotificationCampaigns\Schemas;

use App\Models\NotificationCampaign;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Radio;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Components\Utilities\Get;
use Filament\Schemas\Schema;
use Illuminate\Database\Eloquent\Builder;

class NotificationCampaignForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Message')
                    ->columns(2)
                    ->schema([
                        Select::make('type_notification_id')
                            ->label('Type')
                            ->relationship(
                                name: 'typeNotification',
                                titleAttribute: 'label',
                                modifyQueryUsing: fn (Builder $query) => $query
                                    ->where('actif', true)
                                    ->orderBy('sort_order'),
                            )
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => $record->label.' ('.$record->code.')',
                            )
                            ->searchable()
                            ->preload()
                            ->required(),
                        CheckboxList::make('channels')
                            ->label('Canaux')
                            ->options([
                                NotificationCampaign::CHANNEL_PUSH => 'Push (FCM)',
                                NotificationCampaign::CHANNEL_EMAIL => 'E-mail',
                            ])
                            ->default([NotificationCampaign::CHANNEL_PUSH])
                            ->required()
                            ->columns(2)
                            ->live(),
                        TextInput::make('title')
                            ->label('Titre')
                            ->required()
                            ->maxLength(255)
                            ->columnSpanFull(),
                        Textarea::make('body')
                            ->label('Corps')
                            ->required()
                            ->rows(4)
                            ->columnSpanFull(),
                        TextInput::make('email_subject')
                            ->label('Sujet e-mail')
                            ->maxLength(255)
                            ->helperText('Par défaut : le titre.')
                            ->visible(fn (Get $get): bool => in_array(
                                NotificationCampaign::CHANNEL_EMAIL,
                                $get('channels') ?? [],
                                true,
                            ))
                            ->columnSpanFull(),
                    ]),
                Section::make('Audience')
                    ->columns(2)
                    ->schema([
                        Radio::make('audience_type')
                            ->label('Destinataires')
                            ->options([
                                NotificationCampaign::AUDIENCE_ALL_USERS => 'Tous les utilisateurs actifs',
                                NotificationCampaign::AUDIENCE_SELECTED_USERS => 'Utilisateurs sélectionnés',
                                NotificationCampaign::AUDIENCE_ORGANISATION => 'Par organisation',
                                NotificationCampaign::AUDIENCE_PAYS => 'Par pays',
                            ])
                            ->default(NotificationCampaign::AUDIENCE_ALL_USERS)
                            ->required()
                            ->live()
                            ->columnSpanFull(),
                        Select::make('users')
                            ->label('Utilisateurs')
                            ->relationship(
                                name: 'users',
                                titleAttribute: 'email',
                                modifyQueryUsing: fn (Builder $query) => $query
                                    ->where('statut', 'actif')
                                    ->whereHas('typeUser', fn (Builder $q) => $q->where('code', 'user'))
                                    ->orderBy('email'),
                            )
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => trim(($record->name ?? '').' '.($record->first_name ?? '')).' <'.$record->email.'>',
                            )
                            ->searchable(['name', 'first_name', 'email'])
                            ->multiple()
                            ->preload()
                            ->required()
                            ->visible(fn (Get $get): bool => $get('audience_type') === NotificationCampaign::AUDIENCE_SELECTED_USERS)
                            ->columnSpanFull(),
                        Select::make('organisation_id')
                            ->label('Organisation')
                            ->relationship('organisation', 'label')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->visible(fn (Get $get): bool => $get('audience_type') === NotificationCampaign::AUDIENCE_ORGANISATION),
                        Select::make('pays_id')
                            ->label('Pays')
                            ->relationship('pays', 'label')
                            ->searchable()
                            ->preload()
                            ->required()
                            ->visible(fn (Get $get): bool => $get('audience_type') === NotificationCampaign::AUDIENCE_PAYS),
                    ]),
                Section::make('Appareils (push)')
                    ->columns(2)
                    ->visible(fn (Get $get): bool => in_array(
                        NotificationCampaign::CHANNEL_PUSH,
                        $get('channels') ?? [],
                        true,
                    ))
                    ->schema([
                        Radio::make('device_scope')
                            ->label('Périmètre devices')
                            ->options([
                                NotificationCampaign::DEVICE_SCOPE_ALL => 'Tous les devices actifs des destinataires',
                                NotificationCampaign::DEVICE_SCOPE_SELECTED => 'Devices sélectionnés',
                            ])
                            ->default(NotificationCampaign::DEVICE_SCOPE_ALL)
                            ->required()
                            ->live()
                            ->columnSpanFull(),
                        Select::make('devices')
                            ->label('Devices')
                            ->relationship(
                                name: 'devices',
                                titleAttribute: 'identifier',
                                modifyQueryUsing: fn (Builder $query) => $query
                                    ->where('actif', true)
                                    ->with(['user', 'platform'])
                                    ->orderByDesc('last_used_at'),
                            )
                            ->getOptionLabelFromRecordUsing(function ($record): string {
                                $user = $record->user?->email ?? 'user#'.$record->user_id;
                                $platform = $record->platform?->label ?? '?';
                                $name = $record->name ?: $record->identifier;

                                return "{$name} · {$platform} · {$user}";
                            })
                            ->searchable(['identifier', 'name', 'model'])
                            ->multiple()
                            ->preload()
                            ->required()
                            ->visible(fn (Get $get): bool => $get('device_scope') === NotificationCampaign::DEVICE_SCOPE_SELECTED)
                            ->columnSpanFull(),
                    ]),
                Section::make('Planification')
                    ->columns(2)
                    ->schema([
                        Radio::make('send_mode')
                            ->label('Envoi')
                            ->options([
                                'immediate' => 'Immédiat (file d\'attente)',
                                'scheduled' => 'Planifié',
                            ])
                            ->default('immediate')
                            ->required()
                            ->live()
                            ->dehydrated(false)
                            ->columnSpanFull(),
                        DateTimePicker::make('scheduled_at')
                            ->label('Date d\'envoi')
                            ->seconds(false)
                            ->native(false)
                            ->required(fn (Get $get): bool => $get('send_mode') === 'scheduled')
                            ->visible(fn (Get $get): bool => $get('send_mode') === 'scheduled')
                            ->minDate(now()),
                        TextInput::make('status')
                            ->label('Statut')
                            ->disabled()
                            ->dehydrated(false)
                            ->visibleOn('edit'),
                    ]),
            ]);
    }
}
