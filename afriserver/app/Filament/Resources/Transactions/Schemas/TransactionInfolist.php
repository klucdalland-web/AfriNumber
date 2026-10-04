<?php

namespace App\Filament\Resources\Transactions\Schemas;

use App\Models\Transaction;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class TransactionInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Transaction')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('uid')
                            ->label('UID')
                            ->copyable(),
                        TextEntry::make('status')
                            ->label('Statut')
                            ->badge()
                            ->color(fn (string $state): string => match ($state) {
                                Transaction::STATUS_PAID => 'success',
                                Transaction::STATUS_PENDING => 'warning',
                                Transaction::STATUS_FAILED => 'danger',
                                Transaction::STATUS_EXPIRED => 'gray',
                                default => 'gray',
                            })
                            ->formatStateUsing(fn (string $state): string => match ($state) {
                                Transaction::STATUS_PAID => 'Payée',
                                Transaction::STATUS_PENDING => 'En attente',
                                Transaction::STATUS_FAILED => 'Échouée',
                                Transaction::STATUS_EXPIRED => 'Expirée',
                                default => $state,
                            }),
                        TextEntry::make('user.email')
                            ->label('Utilisateur')
                            ->placeholder('-'),
                        TextEntry::make('typeTransaction.label')
                            ->label('Type')
                            ->placeholder('-'),
                        TextEntry::make('plan.label')
                            ->label('Plan')
                            ->placeholder('-'),
                        TextEntry::make('subscription.id')
                            ->label('Abonnement #')
                            ->placeholder('-'),
                        TextEntry::make('amount')
                            ->label('Montant')
                            ->numeric(decimalPlaces: 2),
                        TextEntry::make('currency')
                            ->label('Devise'),
                        TextEntry::make('payment_method')
                            ->label('Moyen')
                            ->formatStateUsing(fn (string $state): string => match ($state) {
                                Transaction::METHOD_MOMO => 'Mobile Money',
                                Transaction::METHOD_CARD => 'Carte',
                                default => $state,
                            }),
                        TextEntry::make('provider')
                            ->label('Provider')
                            ->placeholder('-'),
                        TextEntry::make('external_ref')
                            ->label('Réf. externe')
                            ->placeholder('-')
                            ->copyable(),
                        TextEntry::make('expires_at')
                            ->label('Expire le')
                            ->dateTime()
                            ->placeholder('-'),
                        TextEntry::make('paid_at')
                            ->label('Payée le')
                            ->dateTime()
                            ->placeholder('-'),
                        TextEntry::make('created_at')
                            ->label('Créée le')
                            ->dateTime(),
                        TextEntry::make('payload')
                            ->label('Payload')
                            ->placeholder('-')
                            ->columnSpanFull()
                            ->formatStateUsing(fn ($state): string => is_array($state)
                                ? (string) json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE)
                                : (string) ($state ?? '-')),
                    ]),
            ]);
    }
}
