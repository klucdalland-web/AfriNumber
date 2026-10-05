<?php

namespace App\Filament\Resources\TypeNotifications;

use App\Filament\Resources\TypeNotifications\Pages\CreateTypeNotification;
use App\Filament\Resources\TypeNotifications\Pages\EditTypeNotification;
use App\Filament\Resources\TypeNotifications\Pages\ListTypeNotifications;
use App\Filament\Resources\TypeNotifications\Schemas\TypeNotificationForm;
use App\Filament\Resources\TypeNotifications\Tables\TypeNotificationsTable;
use App\Models\TypeNotification;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class TypeNotificationResource extends Resource
{
    protected static ?string $model = TypeNotification::class;

    protected static ?string $recordTitleAttribute = 'label';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedBellAlert;

    protected static string|UnitEnum|null $navigationGroup = 'Notifications';

    protected static ?string $modelLabel = 'type de notification';

    protected static ?string $pluralModelLabel = 'types de notification';

    protected static ?string $navigationLabel = 'Types';

    protected static ?int $navigationSort = 1;

    public static function form(Schema $schema): Schema
    {
        return TypeNotificationForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return TypeNotificationsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTypeNotifications::route('/'),
            'create' => CreateTypeNotification::route('/create'),
            'edit' => EditTypeNotification::route('/{record}/edit'),
        ];
    }
}
