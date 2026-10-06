<?php

namespace App\Filament\Resources\Clients\Pages;

use App\Filament\Resources\Clients\ClientResource;
use App\Models\User;
use App\Services\KycAdminService;
use App\Support\PanelPermission;
use Filament\Actions\Action;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ViewRecord;
use Filament\Support\Icons\Heroicon;
use InvalidArgumentException;
use Throwable;

class ViewClient extends ViewRecord
{
    protected static string $resource = ClientResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('approveKyc')
                ->label('Approuver le KYC')
                ->icon(Heroicon::OutlinedCheckCircle)
                ->color('success')
                ->requiresConfirmation()
                ->modalHeading('Approuver ce dossier KYC')
                ->modalDescription('Le compte client sera marqué comme validé et une notification push lui sera envoyée.')
                ->visible(fn (): bool => $this->canManageKyc())
                ->action(function (): void {
                    /** @var User $client */
                    $client = $this->record;

                    try {
                        app(KycAdminService::class)->approve($client);

                        Notification::make()
                            ->title('KYC approuvé')
                            ->body('Le dossier a été validé et le client notifié.')
                            ->success()
                            ->send();
                    } catch (InvalidArgumentException $e) {
                        Notification::make()
                            ->title('Action impossible')
                            ->body($e->getMessage())
                            ->danger()
                            ->send();
                    } catch (Throwable $e) {
                        Notification::make()
                            ->title('Erreur')
                            ->body('La validation a échoué.')
                            ->danger()
                            ->send();

                        report($e);
                    }

                    $this->record->refresh()->load(['profile', 'pays']);
                }),

            Action::make('rejectKyc')
                ->label('Rejeter le KYC')
                ->icon(Heroicon::OutlinedXCircle)
                ->color('danger')
                ->requiresConfirmation()
                ->modalHeading('Rejeter ce dossier KYC')
                ->form([
                    Textarea::make('reason')
                        ->label('Motif du refus')
                        ->required()
                        ->maxLength(1000)
                        ->rows(3),
                ])
                ->visible(fn (): bool => $this->canManageKyc())
                ->action(function (array $data): void {
                    /** @var User $client */
                    $client = $this->record;

                    try {
                        app(KycAdminService::class)->reject(
                            $client,
                            $data['reason'] ?? null,
                        );

                        Notification::make()
                            ->title('KYC rejeté')
                            ->body('Le dossier a été refusé et le client notifié.')
                            ->success()
                            ->send();
                    } catch (InvalidArgumentException $e) {
                        Notification::make()
                            ->title('Action impossible')
                            ->body($e->getMessage())
                            ->danger()
                            ->send();
                    } catch (Throwable $e) {
                        Notification::make()
                            ->title('Erreur')
                            ->body('Le rejet a échoué.')
                            ->danger()
                            ->send();

                        report($e);
                    }

                    $this->record->refresh()->load(['profile', 'pays']);
                }),

            Action::make('updateAccountStatus')
                ->label('Statut du compte')
                ->icon(Heroicon::OutlinedCog6Tooth)
                ->color('gray')
                ->visible(fn (): bool => auth()->user()?->can(PanelPermission::CLIENTS_UPDATE) === true)
                ->form([
                    Select::make('statut')
                        ->label('Statut')
                        ->options([
                            'actif' => 'Actif',
                            'dormant' => 'Dormant',
                            'inactif' => 'Inactif',
                        ])
                        ->required()
                        ->default(fn (): ?string => $this->record instanceof User ? $this->record->statut : null),
                ])
                ->action(function (array $data): void {
                    /** @var User $client */
                    $client = $this->record;
                    $client->update(['statut' => $data['statut']]);

                    Notification::make()
                        ->title('Compte mis à jour')
                        ->body('Le statut du compte est maintenant : '.$data['statut'].'.')
                        ->success()
                        ->send();

                    $this->record->refresh()->load(['profile', 'pays']);
                }),
        ];
    }

    private function canManageKyc(): bool
    {
        if (! $this->record instanceof User) {
            return false;
        }

        if (auth()->user()?->can(PanelPermission::CLIENTS_UPDATE) !== true) {
            return false;
        }

        return $this->record->profile?->isAwaitingManualReview() === true;
    }
}
