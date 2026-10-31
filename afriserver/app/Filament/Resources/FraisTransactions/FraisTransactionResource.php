<?php

namespace App\Filament\Resources\FraisTransactions;

use App\Filament\Resources\FraisTransactions\Pages\CreateFraisTransaction;
use App\Filament\Resources\FraisTransactions\Pages\EditFraisTransaction;
use App\Filament\Resources\FraisTransactions\Pages\ListFraisTransactions;
use App\Filament\Resources\FraisTransactions\Schemas\FraisTransactionForm;
use App\Filament\Resources\FraisTransactions\Tables\FraisTransactionsTable;
use App\Models\FraisTransaction;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class FraisTransactionResource extends Resource
{
    protected static ?string $model = FraisTransaction::class;

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedCurrencyDollar;

    protected static string|UnitEnum|null $navigationGroup = 'Abonnements';

    protected static ?string $modelLabel = 'frais de transaction';

    protected static ?string $pluralModelLabel = 'frais de transaction';

    protected static ?string $navigationLabel = 'Frais';

    protected static ?int $navigationSort = 6;

    public static function form(Schema $schema): Schema
    {
        return FraisTransactionForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return FraisTransactionsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListFraisTransactions::route('/'),
            'create' => CreateFraisTransaction::route('/create'),
            'edit' => EditFraisTransaction::route('/{record}/edit'),
        ];
    }
}
