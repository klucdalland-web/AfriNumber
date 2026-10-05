<?php

namespace App\Filament\Resources\NotificationCampaigns;

use App\Filament\Resources\NotificationCampaigns\Pages\CreateNotificationCampaign;
use App\Filament\Resources\NotificationCampaigns\Pages\EditNotificationCampaign;
use App\Filament\Resources\NotificationCampaigns\Pages\ListNotificationCampaigns;
use App\Filament\Resources\NotificationCampaigns\Pages\ViewNotificationCampaign;
use App\Filament\Resources\NotificationCampaigns\RelationManagers\DeliveriesRelationManager;
use App\Filament\Resources\NotificationCampaigns\Schemas\NotificationCampaignForm;
use App\Filament\Resources\NotificationCampaigns\Tables\NotificationCampaignsTable;
use App\Models\NotificationCampaign;
use BackedEnum;
use Filament\Resources\Resource;
use Filament\Schemas\Schema;
use Filament\Support\Icons\Heroicon;
use Filament\Tables\Table;
use UnitEnum;

class NotificationCampaignResource extends Resource
{
    protected static ?string $model = NotificationCampaign::class;

    protected static ?string $recordTitleAttribute = 'title';

    protected static string|BackedEnum|null $navigationIcon = Heroicon::OutlinedMegaphone;

    protected static string|UnitEnum|null $navigationGroup = 'Notifications';

    protected static ?string $modelLabel = 'campagne';

    protected static ?string $pluralModelLabel = 'campagnes';

    protected static ?string $navigationLabel = 'Campagnes';

    protected static ?int $navigationSort = 2;

    public static function form(Schema $schema): Schema
    {
        return NotificationCampaignForm::configure($schema);
    }

    public static function table(Table $table): Table
    {
        return NotificationCampaignsTable::configure($table);
    }

    public static function getRelations(): array
    {
        return [
            DeliveriesRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => ListNotificationCampaigns::route('/'),
            'create' => CreateNotificationCampaign::route('/create'),
            'view' => ViewNotificationCampaign::route('/{record}'),
            'edit' => EditNotificationCampaign::route('/{record}/edit'),
        ];
    }
}
