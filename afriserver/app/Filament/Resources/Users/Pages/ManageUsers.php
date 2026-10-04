<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Models\TypeUser;
use App\Models\User;
use App\Services\AdminCredentialsMailService;
use Filament\Actions\CreateAction;
use Filament\Notifications\Notification;
use Filament\Resources\Pages\ManageRecords;
use Illuminate\Support\Str;
use Throwable;

class ManageUsers extends ManageRecords
{
    protected static string $resource = UserResource::class;

    protected ?string $generatedPassword = null;

    protected function getHeaderActions(): array
    {
        return [
            CreateAction::make()
                ->label('Nouvel administrateur')
                ->modalHeading('Créer un administrateur')
                ->modalDescription('Un mot de passe temporaire sera généré et envoyé automatiquement par e-mail.')
                ->mutateFormDataUsing(function (array $data): array {
                    $this->generatedPassword = Str::password(12);

                    $adminTypeId = TypeUser::query()->where('code', 'admin')->value('id');

                    if ($adminTypeId === null) {
                        throw new \RuntimeException('Le type utilisateur "admin" est introuvable. Lancez TypeUserSeeder.');
                    }

                    $data['password'] = $this->generatedPassword;
                    $data['type_user_id'] = $adminTypeId;
                    $data['email_verified_at'] = now();
                    $data['status_valide'] = 'valide';
                    $data['statut'] = 'actif';

                    return $data;
                })
                ->after(function (User $record): void {
                    $plainPassword = $this->generatedPassword;
                    $this->generatedPassword = null;

                    if (blank($plainPassword)) {
                        return;
                    }

                    try {
                        app(AdminCredentialsMailService::class)->send($record, $plainPassword);

                        Notification::make()
                            ->title('Administrateur créé')
                            ->body('Les identifiants ont été envoyés à '.$record->email.'.')
                            ->success()
                            ->send();
                    } catch (Throwable $e) {
                        Notification::make()
                            ->title('Compte créé, e-mail non envoyé')
                            ->body('Le compte existe, mais l\'envoi du mot de passe a échoué. Utilisez « Renvoyer MDP ».')
                            ->warning()
                            ->send();

                        report($e);
                    }
                }),
        ];
    }
}
