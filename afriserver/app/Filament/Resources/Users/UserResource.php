<?php

namespace App\Filament\Resources\Users;

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Models\User;
use App\Services\AdminCredentialsMailService;
use BackedEnum;
use Filament\Actions\Action;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Notifications\Notification;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules\Unique;
use Throwable;
use UnitEnum;

class UserResource extends Resource
{
    protected static ?string $model = User::class;

    protected static ?string $recordTitleAttribute = 'email';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedUsers;

    protected static string|UnitEnum|null $navigationGroup = 'Administration';

    protected static ?string $modelLabel = 'administrateur';

    protected static ?string $pluralModelLabel = 'administrateurs';

    protected static ?int $navigationSort = 2;

    public static function getEloquentQuery(): Builder
    {
        return parent::getEloquentQuery()
            ->whereHas('typeUser', fn (Builder $query) => $query->where('code', 'admin'));
    }

    public static function form(Schema $schema): Schema
    {
        return $schema
            ->components([
                TextInput::make('name')
                    ->label('Nom')
                    ->required()
                    ->maxLength(100)
                    ->disabled(fn (?User $record): bool => $record !== null)
                    ->dehydrated(fn (?User $record): bool => $record === null),
                TextInput::make('first_name')
                    ->label('Prénom')
                    ->required()
                    ->maxLength(100)
                    ->disabled(fn (?User $record): bool => $record !== null)
                    ->dehydrated(fn (?User $record): bool => $record === null),
                TextInput::make('email')
                    ->label('Email')
                    ->email()
                    ->required()
                    ->maxLength(255)
                    ->rules([
                        fn (?User $record): Unique => Rule::unique('users', 'email')
                            ->ignore($record),
                    ])
                    ->disabled(fn (?User $record): bool => $record !== null)
                    ->dehydrated(fn (?User $record): bool => $record === null),
                TextInput::make('phone_number')
                    ->label('Téléphone')
                    ->tel()
                    ->required()
                    ->maxLength(30)
                    ->helperText('Format international recommandé (ex. +22990000000).')
                    ->rules([
                        fn (?User $record): Unique => Rule::unique('users', 'phone_number')
                            ->ignore($record),
                    ])
                    ->disabled(fn (?User $record): bool => $record !== null)
                    ->dehydrated(fn (?User $record): bool => $record === null),
                Select::make('roles')
                    ->label('Rôles Spatie')
                    ->relationship('roles', 'name')
                    ->multiple()
                    ->preload()
                    ->searchable()
                    ->helperText('Droits à l\'intérieur du panel (indépendants de TypeUser). Un mot de passe temporaire sera envoyé par e-mail à la création.'),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('name')
                    ->label('Nom')
                    ->description(fn (User $record): ?string => $record->first_name)
                    ->searchable()
                    ->sortable(),
                TextColumn::make('email')
                    ->label('Email')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('phone_number')
                    ->label('Téléphone')
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('roles.name')
                    ->label('Rôles')
                    ->badge()
                    ->separator(','),
            ])
            ->filters([])
            ->recordActions([
                EditAction::make(),
                Action::make('resendCredentials')
                    ->label('Renvoyer MDP')
                    ->icon(Heroicon::OutlinedEnvelope)
                    ->color('warning')
                    ->requiresConfirmation()
                    ->modalHeading('Régénérer et renvoyer le mot de passe')
                    ->modalDescription('Un nouveau mot de passe temporaire sera généré et envoyé par e-mail à cet administrateur.')
                    ->action(function (User $record): void {
                        $plainPassword = Str::password(12);
                        $record->update(['password' => $plainPassword]);

                        try {
                            app(AdminCredentialsMailService::class)->send($record, $plainPassword);

                            Notification::make()
                                ->title('Mot de passe renvoyé')
                                ->body('Un nouveau mot de passe a été envoyé à '.$record->email.'.')
                                ->success()
                                ->send();
                        } catch (Throwable $e) {
                            Notification::make()
                                ->title('Échec de l\'envoi')
                                ->body('Le mot de passe a été régénéré, mais l\'e-mail n\'a pas pu être envoyé.')
                                ->danger()
                                ->send();

                            report($e);
                        }
                    }),
            ])
            ->toolbarActions([
                BulkActionGroup::make([]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageUsers::route('/'),
        ];
    }
}
