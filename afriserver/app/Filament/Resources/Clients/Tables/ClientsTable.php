<?php

namespace App\Filament\Resources\Clients\Tables;

use App\Models\Profile;
use App\Models\User;
use Filament\Actions\ViewAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ClientsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Nom')
                    ->description(fn (User $record): ?string => $record->first_name)
                    ->searchable(['name', 'first_name'])
                    ->sortable(),
                TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->sortable()
                    ->copyable(),
                TextColumn::make('phone_number')
                    ->label('Téléphone')
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('pays.label')
                    ->label('Pays')
                    ->placeholder('-')
                    ->toggleable(),
                TextColumn::make('statut')
                    ->label('Compte')
                    ->badge()
                    ->color(fn (string $state): string => match ($state) {
                        'actif' => 'success',
                        'dormant' => 'warning',
                        'inactif' => 'danger',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (string $state): string => match ($state) {
                        'actif' => 'Actif',
                        'dormant' => 'Dormant',
                        'inactif' => 'Inactif',
                        default => $state,
                    })
                    ->sortable(),
                TextColumn::make('status_valide')
                    ->label('KYC compte')
                    ->badge()
                    ->color(fn (string $state): string => $state === 'valide' ? 'success' : 'warning')
                    ->formatStateUsing(fn (string $state): string => $state === 'valide' ? 'Validé' : 'Non validé')
                    ->sortable(),
                TextColumn::make('profile.status')
                    ->label('Dossier KYC')
                    ->badge()
                    ->placeholder('Aucun')
                    ->color(fn (?string $state): string => match ($state) {
                        Profile::STATUS_APPROUVE => 'success',
                        Profile::STATUS_REJETE => 'danger',
                        Profile::STATUS_VALIDATION_MANUELLE => 'warning',
                        Profile::STATUS_EN_COURS_DE_VERIFICATION => 'info',
                        Profile::STATUS_EN_ATTENTE_D_UPLOAD => 'gray',
                        default => 'gray',
                    })
                    ->formatStateUsing(fn (?string $state): string => match ($state) {
                        Profile::STATUS_APPROUVE => 'Approuvé',
                        Profile::STATUS_REJETE => 'Rejeté',
                        Profile::STATUS_VALIDATION_MANUELLE => 'Validation manuelle',
                        Profile::STATUS_EN_COURS_DE_VERIFICATION => 'Vérification auto',
                        Profile::STATUS_EN_ATTENTE_D_UPLOAD => 'Attente upload',
                        default => $state ?? 'Aucun',
                    }),
                TextColumn::make('created_at')
                    ->label('Inscrit le')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('id', 'desc')
            ->filters([
                SelectFilter::make('statut')
                    ->label('Compte')
                    ->options([
                        'actif' => 'Actif',
                        'dormant' => 'Dormant',
                        'inactif' => 'Inactif',
                    ]),
                SelectFilter::make('status_valide')
                    ->label('KYC compte')
                    ->options([
                        'valide' => 'Validé',
                        'non_valide' => 'Non validé',
                    ]),
                SelectFilter::make('profile_status')
                    ->label('Dossier KYC')
                    ->options([
                        Profile::STATUS_VALIDATION_MANUELLE => 'Validation manuelle',
                        Profile::STATUS_EN_COURS_DE_VERIFICATION => 'Vérification auto',
                        Profile::STATUS_EN_ATTENTE_D_UPLOAD => 'Attente upload',
                        Profile::STATUS_APPROUVE => 'Approuvé',
                        Profile::STATUS_REJETE => 'Rejeté',
                        'aucun' => 'Aucun dossier',
                    ])
                    ->query(function (Builder $query, array $data): Builder {
                        $value = $data['value'] ?? null;

                        if ($value === null || $value === '') {
                            return $query;
                        }

                        if ($value === 'aucun') {
                            return $query->whereDoesntHave('profile');
                        }

                        return $query->whereHas(
                            'profile',
                            fn (Builder $q): Builder => $q->where('status', $value),
                        );
                    }),
            ])
            ->recordUrl(fn (User $record): string => \App\Filament\Resources\Clients\ClientResource::getUrl('view', ['record' => $record]))
            ->recordActions([
                ViewAction::make(),
            ])
            ->toolbarActions([]);
    }
}
