<?php

namespace App\Filament\Resources\Continents;

use App\Filament\Resources\Continents\Pages\CreateContinent;
use App\Filament\Resources\Continents\Pages\EditContinent;
use App\Filament\Resources\Continents\Pages\ListContinents;
use App\Filament\Resources\Continents\Schemas\ContinentForm;
use App\Filament\Resources\Continents\Tables\ContinentsTable;
use App\Models\Continent;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class ContinentResource extends Resource
{
    protected static ?string $model = Continent::class;

    protected static ?string $recordTitleAttribute = 'label';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedGlobeAlt;

    protected static string|UnitEnum|null $navigationGroup = 'Localisation';

    protected static ?string $modelLabel = 'continent';

    protected static ?string $pluralModelLabel = 'continents';

    protected static ?int $navigationSort = 1;

    public static function form(Schema $schema): Schema
    {
        return ContinentForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return ContinentsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListContinents::route('/'),
            'create' => CreateContinent::route('/create'),
            'edit' => EditContinent::route('/{record}/edit'),
        ];
    }
}
