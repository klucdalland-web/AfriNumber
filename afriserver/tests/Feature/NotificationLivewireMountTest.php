<?php

use App\Filament\Resources\NotificationCampaigns\Pages\CreateNotificationCampaign;
use App\Filament\Resources\NotificationCampaigns\Pages\ListNotificationCampaigns;
use App\Filament\Resources\NotificationCampaigns\Pages\ViewNotificationCampaign;
use App\Filament\Resources\TypeNotifications\Pages\ListTypeNotifications;
use App\Models\NotificationCampaign;
use App\Models\TypeNotification;
use App\Models\TypeUser;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Database\Seeders\TypeNotificationSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Filament::setCurrentPanel(Filament::getPanel('afriNetAdmin'));
    TypeUser::query()->updateOrCreate(['code' => 'admin'], ['label' => 'Administrateur', 'description' => 'Administrateur système', 'actif' => true]);
    $this->seed(RolesAndPermissionsSeeder::class);
    $this->seed(TypeNotificationSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

test('livewire mounts notification pages', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');
    $this->actingAs($admin);

    Livewire::test(ListTypeNotifications::class)->assertSuccessful();
    Livewire::test(ListNotificationCampaigns::class)->assertSuccessful();
    Livewire::test(CreateNotificationCampaign::class)->assertSuccessful();

    $type = TypeNotification::query()->firstOrFail();
    $campaign = NotificationCampaign::query()->create([
        'sent_by' => $admin->id,
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_PUSH],
        'audience_type' => NotificationCampaign::AUDIENCE_ALL_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Test',
        'body' => 'Body',
        'status' => NotificationCampaign::STATUS_COMPLETED,
    ]);

    Livewire::test(ViewNotificationCampaign::class, ['record' => $campaign->getRouteKey()])->assertSuccessful();
});
