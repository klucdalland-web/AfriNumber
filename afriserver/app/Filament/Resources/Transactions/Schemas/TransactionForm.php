<?php

namespace App\Filament\Resources\Transactions\Schemas;

use App\Models\Transaction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class TransactionForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Transaction')
                    ->columns(2)
                    ->schema([
                        TextInput::make('uid')
                            ->label('UID')
                            ->disabled()
                            ->dehydrated(false)
                            ->placeholder('Généré automatiquement')
                            ->visibleOn('edit'),
                        Select::make('user_id')
                            ->label('Utilisateur')
                            ->relationship('user', 'email')
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => trim(($record->name ?? '').' <'.$record->email.'>'),
                            )
                            ->searchable(['name', 'email'])
                            ->preload()
                            ->required(),
                        Select::make('type_transaction_id')
                            ->label('Type')
                            ->relationship(
                                name: 'typeTransaction',
                                titleAttribute: 'label',
                                modifyQueryUsing: fn ($query) => $query->where('actif', true)->orderBy('sort_order'),
                            )
                            ->getOptionLabelFromRecordUsing(
                                fn ($record): string => $record->label.' ('.$record->code.')',
                            )
                            ->searchable()
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
                                fn ($record): string => $record->label.' ('.$record->code.')',
                            )
                            ->searchable()
                            ->preload()
                            ->nullable(),
                        Select::make('subscription_id')
                            ->label('Abonnement')
                            ->relationship('subscription', 'id')
                            ->searchable()
                            ->preload()
                            ->nullable(),
                        TextInput::make('amount')
                            ->label('Montant')
                            ->required()
                            ->numeric()
                            ->minValue(0),
                        TextInput::make('currency')
                            ->label('Devise')
                            ->required()
                            ->maxLength(3)
                            ->default('XOF'),
                        Select::make('payment_method')
                            ->label('Moyen de paiement')
                            ->options([
                                Transaction::METHOD_MOMO => 'Mobile Money',
                                Transaction::METHOD_CARD => 'Carte',
                            ])
                            ->required(),
                        TextInput::make('provider')
                            ->label('Provider')
                            ->maxLength(100)
                            ->placeholder('mtn, airtel, mvola, stripe…'),
                        TextInput::make('external_ref')
                            ->label('Réf. externe')
                            ->maxLength(255),
                        Select::make('status')
                            ->label('Statut')
                            ->options([
                                Transaction::STATUS_PENDING => 'En attente',
                                Transaction::STATUS_PAID => 'Payée',
                                Transaction::STATUS_FAILED => 'Échouée',
                                Transaction::STATUS_EXPIRED => 'Expirée',
                            ])
                            ->required()
                            ->default(Transaction::STATUS_PENDING),
                        DateTimePicker::make('expires_at')
                            ->label('Expire le')
                            ->seconds(false),
                        DateTimePicker::make('paid_at')
                            ->label('Payée le')
                            ->seconds(false),
                        Textarea::make('payload')
                            ->label('Payload')
                            ->rows(4)
                            ->columnSpanFull()
                            ->helperText('JSON optionnel (détails provider / checkout).')
                            ->formatStateUsing(fn ($state): string => is_array($state)
                                ? (string) json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
                                : (string) ($state ?? ''))
                            ->dehydrateStateUsing(function (?string $state): ?array {
                                if (blank($state)) {
                                    return null;
                                }

                                $decoded = json_decode($state, true);

                                return is_array($decoded) ? $decoded : null;
                            }),
                    ]),
            ]);
    }
}
