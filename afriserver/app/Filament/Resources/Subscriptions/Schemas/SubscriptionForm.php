<?php

namespace App\Filament\Resources\Subscriptions\Schemas;

use App\Models\Subscription;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class SubscriptionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Abonnement')
                    ->columns(2)
                    ->schema([
                        Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'email')
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => trim(($record->name ?? '').' <'.$record->email.'>'),
                            )
                            ->searchable(['name', 'email'])
                            ->preload()
                            ->required(),
                        Select::make('plan_id')
                            ->label('Plan')
                            ->relationship(
                                name: 'plan',
                                titleAttribute: 'label',
                                modifyQueryUsing: fn ($query) => $query->orderBy('sort_order'),
                            )
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => $record->label.' ('.$record->code.')'
                                    .($record->is_active ? '' : ' — inactif'),
                            )
                            ->searchable()
                            ->preload()
                            ->required(),
                        Select::make('status')
                            ->label('Statut')
                            ->options([
                                Subscription::STATUS_PENDING => 'En attente',
                                Subscription::STATUS_ACTIVE => 'Actif',
                                Subscription::STATUS_EXPIRED => 'Expiré',
                                Subscription::STATUS_CANCELLED => 'Annulé',
                            ])
                            ->required()
                            ->default(Subscription::STATUS_PENDING),
                        Toggle::make('auto_renew')
                            ->label('Renouvellement auto')
                            ->default(false)
                            ->required(),
                        DateTimePicker::make('starts_at')
                            ->label('Début')
                            ->seconds(false),
                        DateTimePicker::make('ends_at')
                            ->label('Fin')
                            ->seconds(false)
                            ->after('starts_at'),
                        DateTimePicker::make('cancelled_at')
                            ->label('Annulé le')
                            ->seconds(false)
                            ->nullable(),
                    ]),
            ]);
    }
}
