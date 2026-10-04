<?php

namespace App\Filament\Resources\Transactions\Tables;

use App\Models\Transaction;
use Carbon\Carbon;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Actions\ViewAction;
use Filament\Forms\Components\DatePicker;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\Indicator;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class TransactionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('uid')
                    ->label('UID')
                    ->searchable()
                    ->copyable()
                    ->limit(13)
                    ->tooltip(fn (Transaction $record): string => $record->uid),
                TextColumn::make('user.email')
                    ->label('Utilisateur')
                    ->description(fn (Transaction $record): ?string => $record->user?->name)
                    ->searchable()
                    ->sortable(),
                TextColumn::make('typeTransaction.label')
                    ->label('Type')
                    ->description(fn (Transaction $record): ?string => $record->typeTransaction?->code)
                    ->sortable(),
                TextColumn::make('plan.label')
                    ->label('Plan')
                    ->placeholder('-')
                    ->toggleable(),
                TextColumn::make('amount')
                    ->label('Montant')
                    ->numeric(decimalPlaces: 2)
                    ->sortable()
                    ->description(fn (Transaction $record): string => $record->currency),
                TextColumn::make('payment_method')
                    ->label('Moyen')
                    ->badge()
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        Transaction::METHOD_MOMO => 'MoMo',
                        Transaction::METHOD_CARD => 'Carte',
                        default => $state,
                    }),
                TextColumn::make('provider')
                    ->label('Provider')
                    ->placeholder('-')
                    ->toggleable(),
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
                    })
                    ->sortable(),
                TextColumn::make('external_ref')
                    ->label('Réf. externe')
                    ->searchable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('paid_at')
                    ->label('Payée le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('created_at')
                    ->label('Créée le')
                    ->dateTime()
                    ->sortable(),
            ])
            ->defaultSort('id', 'desc')
            ->filters([
                SelectFilter::make('status')
                    ->label('Statut')
                    ->options([
                        Transaction::STATUS_PENDING => 'En attente',
                        Transaction::STATUS_PAID => 'Payée',
                        Transaction::STATUS_FAILED => 'Échouée',
                        Transaction::STATUS_EXPIRED => 'Expirée',
                    ]),
                SelectFilter::make('type_transaction_id')
                    ->label('Type')
                    ->relationship('typeTransaction', 'label'),
                SelectFilter::make('payment_method')
                    ->label('Moyen de paiement')
                    ->options([
                        Transaction::METHOD_MOMO => 'Mobile Money',
                        Transaction::METHOD_CARD => 'Carte',
                    ]),
                SelectFilter::make('provider')
                    ->label('Provider')
                    ->options(fn (): array => Transaction::query()
                        ->whereNotNull('provider')
                        ->distinct()
                        ->orderBy('provider')
                        ->pluck('provider', 'provider')
                        ->all()),
                SelectFilter::make('plan_id')
                    ->label('Plan')
                    ->relationship('plan', 'label'),
                SelectFilter::make('user_id')
                    ->label('Utilisateur')
                    ->relationship('user', 'email')
                    ->searchable()
                    ->preload(),
                Filter::make('created_at')
                    ->label('Date de création')
                    ->schema([
                        DatePicker::make('created_from')
                            ->label('Du'),
                        DatePicker::make('created_until')
                            ->label('Au'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['created_from'] ?? null,
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '>=', $date),
                            )
                            ->when(
                                $data['created_until'] ?? null,
                                fn (Builder $query, $date): Builder => $query->whereDate('created_at', '<=', $date),
                            );
                    })
                    ->indicateUsing(function (array $data): array {
                        $indicators = [];

                        if ($data['created_from'] ?? null) {
                            $indicators[] = Indicator::make('Créée du '.Carbon::parse($data['created_from'])->toFormattedDateString())
                                ->removeField('created_from');
                        }

                        if ($data['created_until'] ?? null) {
                            $indicators[] = Indicator::make('Créée au '.Carbon::parse($data['created_until'])->toFormattedDateString())
                                ->removeField('created_until');
                        }

                        return $indicators;
                    }),
                Filter::make('paid_at')
                    ->label('Date de paiement')
                    ->schema([
                        DatePicker::make('paid_from')
                            ->label('Payée du'),
                        DatePicker::make('paid_until')
                            ->label('Payée au'),
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        return $query
                            ->when(
                                $data['paid_from'] ?? null,
                                fn (Builder $query, $date): Builder => $query->whereDate('paid_at', '>=', $date),
                            )
                            ->when(
                                $data['paid_until'] ?? null,
                                fn (Builder $query, $date): Builder => $query->whereDate('paid_at', '<=', $date),
                            );
                    })
                    ->indicateUsing(function (array $data): array {
                        $indicators = [];

                        if ($data['paid_from'] ?? null) {
                            $indicators[] = Indicator::make('Payée du '.Carbon::parse($data['paid_from'])->toFormattedDateString())
                                ->removeField('paid_from');
                        }

                        if ($data['paid_until'] ?? null) {
                            $indicators[] = Indicator::make('Payée au '.Carbon::parse($data['paid_until'])->toFormattedDateString())
                                ->removeField('paid_until');
                        }

                        return $indicators;
                    }),
            ])
            ->recordActions([
                ViewAction::make(),
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
