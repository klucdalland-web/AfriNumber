<?php

namespace App\Filament\Resources\Pays;

use App\Filament\Resources\Pays\Pages\CreatePays;
use App\Filament\Resources\Pays\Pages\EditPays;
use App\Filament\Resources\Pays\Pages\ListPays;
use App\Filament\Resources\Pays\Schemas\PaysForm;
use App\Filament\Resources\Pays\Tables\PaysTable;
use App\Models\Pays;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class PaysResource extends Resource
{
    protected static ?string $model = Pays::class;

    protected static ?string $recordTitleAttribute = 'label';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMap;

    protected static string|UnitEnum|null $navigationGroup = 'Localisation';

    protected static ?string $modelLabel = 'pays';

    protected static ?string $pluralModelLabel = 'pays';

    protected static ?string $navigationLabel = 'Pays';

    protected static ?int $navigationSort = 3;

    public static function form(Schema $schema): Schema
    {
        return PaysForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return PaysTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListPays::route('/'),
            'create' => CreatePays::route('/create'),
            'edit' => EditPays::route('/{record}/edit'),
        ];
    }
}
