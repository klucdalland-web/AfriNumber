<?php

namespace App\Filament\Resources\TypeTransactions;

use App\Filament\Resources\TypeTransactions\Pages\CreateTypeTransaction;
use App\Filament\Resources\TypeTransactions\Pages\EditTypeTransaction;
use App\Filament\Resources\TypeTransactions\Pages\ListTypeTransactions;
use App\Filament\Resources\TypeTransactions\Schemas\TypeTransactionForm;
use App\Filament\Resources\TypeTransactions\Tables\TypeTransactionsTable;
use App\Models\TypeTransaction;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class TypeTransactionResource extends Resource
{
    protected static ?string $model = TypeTransaction::class;

    protected static ?string $recordTitleAttribute = 'label';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedTag;

    protected static string|UnitEnum|null $navigationGroup = 'Abonnements';

    protected static ?string $modelLabel = 'type de transaction';

    protected static ?string $pluralModelLabel = 'types de transaction';

    protected static ?string $navigationLabel = 'Types de tx';

    protected static ?int $navigationSort = 4;

    public static function form(Schema $schema): Schema
    {
        return TypeTransactionForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return TypeTransactionsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListTypeTransactions::route('/'),
            'create' => CreateTypeTransaction::route('/create'),
            'edit' => EditTypeTransaction::route('/{record}/edit'),
        ];
    }
}
