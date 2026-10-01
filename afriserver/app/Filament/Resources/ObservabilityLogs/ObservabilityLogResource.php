<?php

namespace App\Filament\Resources\ObservabilityLogs;

use App\Filament\Resources\ObservabilityLogs\Pages\ManageObservabilityLogs;
use App\Models\ObservabilityLog;
use App\Support\GeoMapUrl;
use BackedEnum;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteAction;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\ViewAction;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Components\ViewEntry;
use Filament\Resources\Resource;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use UnitEnum;

class ObservabilityLogResource extends Resource
{
    protected static ?string $model = ObservabilityLog::class;

    protected static ?string $recordTitleAttribute = 'action';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedClipboardDocumentList;

    protected static string|UnitEnum|null $navigationGroup = 'Sécurité';

    protected static ?string $modelLabel = 'log';

    protected static ?string $pluralModelLabel = 'logs d\'observabilité';

    protected static ?string $navigationLabel = 'Observabilité';

    protected static ?int $navigationSort = 20;

    public static function form(Schema $schema): Schema
    {
        return $schema->components([]);
    }

    public static function infolist(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Événement')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('created_at')
                            ->label('Date')
                            ->dateTime(),
                        TextEntry::make('level')
                            ->label('Niveau')
                            ->badge(),
                        TextEntry::make('category')
                            ->label('Catégorie'),
                        TextEntry::make('action')
                            ->label('Action'),
                        TextEntry::make('message')
                            ->label('Message')
                            ->placeholder('-')
                            ->columnSpanFull(),
                    ]),
                Section::make('Contexte requête')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('user.email')
                            ->label('Utilisateur')
                            ->placeholder('-'),
                        TextEntry::make('device.name')
                            ->label('Device')
                            ->placeholder('-'),
                        TextEntry::make('device_identifier')
                            ->label('Identifiant device')
                            ->placeholder('-'),
                        TextEntry::make('ip_address')
                            ->label('IP')
                            ->placeholder('-'),
                        TextEntry::make('method')
                            ->label('Méthode')
                            ->placeholder('-'),
                        TextEntry::make('status_code')
                            ->label('Status')
                            ->placeholder('-'),
                        TextEntry::make('path')
                            ->label('Path')
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('route_name')
                            ->label('Route')
                            ->placeholder('-'),
                        TextEntry::make('duration_ms')
                            ->label('Durée (ms)')
                            ->placeholder('-'),
                        TextEntry::make('user_agent')
                            ->label('User-Agent')
                            ->placeholder('-')
                            ->columnSpanFull(),
                    ]),
                Section::make('Localisation')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('location_label')
                            ->label('Lieu')
                            ->state(fn (ObservabilityLog $record): ?string => GeoMapUrl::label($record->location))
                            ->placeholder('-'),
                        TextEntry::make('location_maps')
                            ->label('Carte')
                            ->state(fn (ObservabilityLog $record): ?string => GeoMapUrl::fromLocation($record->location) ? 'Voir sur Google Maps' : null)
                            ->url(fn (ObservabilityLog $record): ?string => GeoMapUrl::fromLocation($record->location))
                            ->openUrlInNewTab()
                            ->placeholder('Coordonnées indisponibles'),
                        TextEntry::make('location.latitude')
                            ->label('Latitude')
                            ->placeholder('-'),
                        TextEntry::make('location.longitude')
                            ->label('Longitude')
                            ->placeholder('-'),
                        ViewEntry::make('location_map')
                            ->label('Aperçu')
                            ->view('filament.infolists.location-map')
                            ->columnSpanFull()
                            ->visible(fn (ObservabilityLog $record): bool => GeoMapUrl::fromLocation($record->location) !== null),
                    ]),
                Section::make('Données')
                    ->collapsed()
                    ->schema([
                        TextEntry::make('request_payload')
                            ->label('Payload')
                            ->formatStateUsing(fn ($state): string => self::formatJson($state))
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('context')
                            ->label('Context')
                            ->formatStateUsing(fn ($state): string => self::formatJson($state))
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('data_before')
                            ->label('Avant')
                            ->formatStateUsing(fn ($state): string => self::formatJson($state))
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('data_after')
                            ->label('Après')
                            ->formatStateUsing(fn ($state): string => self::formatJson($state))
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('session')
                            ->label('Session')
                            ->formatStateUsing(fn ($state): string => self::formatJson($state))
                            ->placeholder('-')
                            ->columnSpanFull(),
                        TextEntry::make('error')
                            ->label('Erreur')
                            ->formatStateUsing(fn ($state): string => self::formatJson($state))
                            ->placeholder('-')
                            ->columnSpanFull(),
                    ]),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->defaultSort('id', 'desc')
            ->columns([
                TextColumn::make('created_at')
                    ->label('Date')
                    ->dateTime()
                    ->sortable(),
                TextColumn::make('level')
                    ->label('Niveau')
                    ->badge()
                    ->searchable()
                    ->sortable(),
                TextColumn::make('category')
                    ->label('Catégorie')
                    ->searchable()
                    ->sortable(),
                TextColumn::make('action')
                    ->label('Action')
                    ->searchable()
                    ->sortable()
                    ->wrap(),
                TextColumn::make('user.email')
                    ->label('Utilisateur')
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('ip_address')
                    ->label('IP')
                    ->searchable()
                    ->toggleable(),
                TextColumn::make('location')
                    ->label('Localisation')
                    ->formatStateUsing(fn ($state): string => GeoMapUrl::label(is_array($state) ? $state : null) ?? '—')
                    ->url(fn (ObservabilityLog $record): ?string => GeoMapUrl::fromLocation($record->location))
                    ->openUrlInNewTab()
                    ->toggleable(),
                TextColumn::make('status_code')
                    ->label('Status')
                    ->sortable()
                    ->toggleable(),
                TextColumn::make('message')
                    ->label('Message')
                    ->limit(50)
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([
                SelectFilter::make('category')
                    ->label('Catégorie')
                    ->options(fn (): array => ObservabilityLog::query()
                        ->whereNotNull('category')
                        ->distinct()
                        ->orderBy('category')
                        ->pluck('category', 'category')
                        ->all()),
                SelectFilter::make('level')
                    ->label('Niveau')
                    ->options(fn (): array => ObservabilityLog::query()
                        ->whereNotNull('level')
                        ->distinct()
                        ->orderBy('level')
                        ->pluck('level', 'level')
                        ->all()),
                SelectFilter::make('action')
                    ->label('Action')
                    ->options(fn (): array => ObservabilityLog::query()
                        ->whereNotNull('action')
                        ->distinct()
                        ->orderBy('action')
                        ->pluck('action', 'action')
                        ->all())
                    ->searchable(),
            ])
            ->recordActions([
                ViewAction::make(),
                DeleteAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function canCreate(): bool
    {
        return false;
    }

    public static function getPages(): array
    {
        return [
            'index' => ManageObservabilityLogs::route('/'),
        ];
    }

    private static function formatJson(mixed $state): string
    {
        if ($state === null || $state === []) {
            return '-';
        }

        if (is_string($state)) {
            return $state;
        }

        return json_encode($state, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '-';
    }
}
