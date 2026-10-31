<?php

namespace App\Filament\Resources\FraisTransactions\Tables;

use App\Models\FraisTransaction;
use App\Models\Pays;
use App\Services\ObservabilityService;
use App\Support\PanelPermission;
use Filament\Actions\Action;
use Filament\Actions\EditAction;
use Filament\Notifications\Notification;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class FraisTransactionsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('typeTransaction.code')
                    ->label('Type')
                    ->badge()
                    ->searchable()
                    ->sortable(),
                TextColumn::make('typeTransaction.label')
                    ->label('Libellé type')
                    ->toggleable()
                    ->searchable(),
                TextColumn::make('pays.label')
                    ->label('Pays')
                    ->placeholder('Tous les pays')
                    ->sortable()
                    ->searchable(),
                TextColumn::make('montant_fixe')
                    ->label('Fixe (USD)')
                    ->sortable(),
                TextColumn::make('taux_pourcentage')
                    ->label('Taux (%)')
                    ->sortable(),
                TextColumn::make('montant_min')
                    ->label('Min')
                    ->placeholder('—')
                    ->toggleable(),
                TextColumn::make('montant_max')
                    ->label('Max')
                    ->placeholder('—')
                    ->toggleable(),
                TextColumn::make('statut')
                    ->label('Statut')
                    ->badge()
                    ->color(fn (string $state): string => $state === FraisTransaction::STATUT_ACTIF ? 'success' : 'gray')
                    ->sortable(),
                TextColumn::make('updated_at')
                    ->label('Mis à jour')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('id', 'desc')
            ->filters([
                SelectFilter::make('type_transaction_id')
                    ->label('Type de transaction')
                    ->relationship('typeTransaction', 'label')
                    ->searchable()
                    ->preload(),
                SelectFilter::make('pays_filter')
                    ->label('Pays')
                    ->options(fn (): array => [
                        '__default__' => 'Tous les pays (règle par défaut)',
                        ...Pays::query()->orderBy('label')->pluck('label', 'id')->all(),
                    ])
                    ->searchable()
                    ->query(function (Builder $query, array $data): Builder {
                        $value = $data['value'] ?? null;

                        if ($value === null || $value === '') {
                            return $query;
                        }

                        if ($value === '__default__') {
                            return $query->whereNull('pays_id');
                        }

                        return $query->where('pays_id', $value);
                    }),
            ])
            ->recordActions([
                EditAction::make(),
                Action::make('toggleStatut')
                    ->label(fn (FraisTransaction $record): string => $record->statut === FraisTransaction::STATUT_ACTIF
                        ? 'Désactiver'
                        : 'Activer')
                    ->icon(fn (FraisTransaction $record): Heroicon => $record->statut === FraisTransaction::STATUT_ACTIF
                        ? Heroicon::OutlinedXCircle
                        : Heroicon::OutlinedCheckCircle)
                    ->color(fn (FraisTransaction $record): string => $record->statut === FraisTransaction::STATUT_ACTIF
                        ? 'warning'
                        : 'success')
                    ->requiresConfirmation()
                    ->visible(fn (): bool => auth()->user()?->can(PanelPermission::FRAIS_GERER) === true)
                    ->action(function (FraisTransaction $record): void {
                        $before = $record->only([
                            'id',
                            'type_transaction_id',
                            'pays_id',
                            'montant_fixe',
                            'taux_pourcentage',
                            'montant_min',
                            'montant_max',
                            'statut',
                        ]);

                        $nouveauStatut = $record->statut === FraisTransaction::STATUT_ACTIF
                            ? FraisTransaction::STATUT_INACTIF
                            : FraisTransaction::STATUT_ACTIF;

                        $record->update(['statut' => $nouveauStatut]);

                        app(ObservabilityService::class)->action(
                            category: 'frais',
                            action: 'frais.statut_changed',
                            message: 'Statut des frais de transaction modifié',
                            context: ['frais_transaction_id' => $record->id],
                            dataBefore: $before,
                            dataAfter: $record->fresh()?->only([
                                'id',
                                'type_transaction_id',
                                'pays_id',
                                'montant_fixe',
                                'taux_pourcentage',
                                'montant_min',
                                'montant_max',
                                'statut',
                            ]),
                            user: auth()->user(),
                        );

                        Notification::make()
                            ->title('Statut mis à jour')
                            ->body('La règle est maintenant : '.$nouveauStatut.'.')
                            ->success()
                            ->send();
                    }),
            ])
            ->toolbarActions([]);
    }
}
