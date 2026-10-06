<?php

namespace App\Filament\Resources\Clients\Schemas;

use App\Models\Profile;
use App\Models\User;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ClientInfolist
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Identité')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('name')
                            ->label('Nom'),
                        TextEntry::make('first_name')
                            ->label('Prénom')
                            ->placeholder('-'),
                        TextEntry::make('email')
                            ->label('Email')
                            ->copyable(),
                        TextEntry::make('phone_number')
                            ->label('Téléphone')
                            ->copyable()
                            ->placeholder('-'),
                        TextEntry::make('pays.label')
                            ->label('Pays')
                            ->placeholder('-'),
                        TextEntry::make('created_at')
                            ->label('Inscrit le')
                            ->dateTime(),
                    ]),

                Section::make('Compte')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('statut')
                            ->label('Statut compte')
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
                            }),
                        TextEntry::make('status_valide')
                            ->label('Validation compte')
                            ->badge()
                            ->color(fn (string $state): string => $state === 'valide' ? 'success' : 'warning')
                            ->formatStateUsing(fn (string $state): string => $state === 'valide' ? 'Validé' : 'Non validé'),
                        TextEntry::make('email_verified_at')
                            ->label('Email vérifié le')
                            ->dateTime()
                            ->placeholder('Non vérifié'),
                        TextEntry::make('locked_until')
                            ->label('Verrouillé jusqu\'au')
                            ->dateTime()
                            ->placeholder('Non'),
                    ]),

                Section::make('Dossier KYC')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('profile.id')
                            ->label('ID dossier')
                            ->copyable()
                            ->placeholder('Aucun dossier'),
                        TextEntry::make('profile.status')
                            ->label('Statut dossier')
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
                                Profile::STATUS_EN_COURS_DE_VERIFICATION => 'Vérification automatique',
                                Profile::STATUS_EN_ATTENTE_D_UPLOAD => 'En attente d\'upload',
                                default => $state ?? 'Aucun',
                            }),
                        TextEntry::make('profile.rejection_reason')
                            ->label('Motif (refus / revue)')
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('profile.updated_at')
                            ->label('Dernière mise à jour KYC')
                            ->dateTime()
                            ->placeholder('-'),
                    ]),

                Section::make('Documents KYC')
                    ->description('Visibles tant que le dossier est en revue (conservés après `manual_review`).')
                    ->columns(3)
                    ->visible(fn (User $record): bool => filled($record->profile?->documents))
                    ->schema([
                        ImageEntry::make('kyc_selfie')
                            ->label('Selfie')
                            ->state(fn (User $record): ?string => $record->profile?->temporaryDocumentUrl('photopath'))
                            ->imageHeight(180)
                            ->checkFileExistence(false),
                        ImageEntry::make('kyc_piece_avant')
                            ->label('Pièce (recto)')
                            ->state(fn (User $record): ?string => $record->profile?->temporaryDocumentUrl('pieceavantpath'))
                            ->imageHeight(180)
                            ->checkFileExistence(false),
                        ImageEntry::make('kyc_piece_arriere')
                            ->label('Pièce (verso)')
                            ->state(fn (User $record): ?string => $record->profile?->temporaryDocumentUrl('piecearrierepath'))
                            ->imageHeight(180)
                            ->checkFileExistence(false),
                    ]),
            ]);
    }
}
