<?php

namespace App\Filament\Resources\Clients\RelationManagers;

use App\Models\Transaction;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;

class TransactionsRelationManager extends RelationManager
{
    protected static string $relationship = 'transactions';

    protected static ?string $title = 'Transactions';

    public function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('uid')
                    ->label('UID')
                    ->copyable()
                    ->limit(13),
                TextColumn::make('typeTransaction.label')
                    ->label('Type')
                    ->placeholder('-'),
                TextColumn::make('amount')
                    ->label('Montant')
                    ->numeric(decimalPlaces: 2)
                    ->description(fn (Transaction $record): string => $record->currency),
                TextColumn::make('status')
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
                TextColumn::make('paid_at')
                    ->label('Payée le')
                    ->dateTime()
                    ->placeholder('-'),
                TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('id', 'desc')
            ->headerActions([])
            ->recordActions([])
            ->toolbarActions([]);
    }
}
