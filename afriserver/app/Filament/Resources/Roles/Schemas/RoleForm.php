<?php

namespace App\Filament\Resources\Roles\Schemas;

use App\Models\User;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class RoleForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Rôle')
                    ->schema([
                        TextInput::make('name')
                            ->label('Nom')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->maxLength(255),
                        TextInput::make('guard_name')
                            ->label('Guard')
                            ->default('web')
                            ->required()
                            ->maxLength(255),
                    ]),
                Section::make('Permissions')
                    ->schema([
                        CheckboxList::make('permissions')
                            ->label('Permissions')
                            ->relationship('permissions', 'name')
                            ->columns(2)
                            ->searchable()
                            ->bulkToggleable(),
                    ]),
                Section::make('Admins assignés')
                    ->description('Attribuer ce rôle aux comptes admin du panel.')
                    ->schema([
                        Select::make('users')
                            ->label('Administrateurs')
                            ->relationship(
                                name: 'users',
                                titleAttribute: 'email',
                                modifyQueryUsing: fn ($query) => $query
                                    ->whereHas('typeUser', fn ($q) => $q->where('code', 'admin'))
                                    ->orderBy('email'),
                            )
                            ->getOptionLabelFromRecordUsing(
                                fn (User $record): string => trim(($record->name ?? '').' <'.$record->email.'>'),
                            )
                            ->multiple()
                            ->preload()
                            ->searchable(),
                    ]),
            ]);
    }
}
