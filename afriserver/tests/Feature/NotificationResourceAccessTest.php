<?php

use App\Filament\Resources\NotificationCampaigns\NotificationCampaignResource;
use App\Filament\Resources\TypeNotifications\TypeNotificationResource;
use App\Models\NotificationCampaign;
use App\Models\TypeNotification;
use App\Models\TypeUser;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Database\Seeders\TypeNotificationSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Filament::setCurrentPanel(Filament::getPanel('afriNetAdmin'));

    TypeUser::query()->updateOrCreate(
        ['code' => 'admin'],
        [
            'label' => 'Administrateur',
            'description' => 'Administrateur système',
            'actif' => true,
        ],
    );

    $this->seed(RolesAndPermissionsSeeder::class);
    $this->seed(TypeNotificationSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

test('super_admin can open notification resources', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $this->actingAs($admin);

    expect(TypeNotificationResource::canViewAny())->toBeTrue()
        ->and(NotificationCampaignResource::canViewAny())->toBeTrue();

    $this->get(TypeNotificationResource::getUrl('index'))->assertOk();
    $this->get(TypeNotificationResource::getUrl('create'))->assertOk();
    $this->get(NotificationCampaignResource::getUrl('index'))->assertOk();
    $this->get(NotificationCampaignResource::getUrl('create'))->assertOk();
});

test('super_admin can view a notification campaign', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');
    $this->actingAs($admin);

    $type = TypeNotification::query()->firstOrFail();

    $campaign = NotificationCampaign::query()->create([
        'sent_by' => $admin->id,
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_PUSH],
        'audience_type' => NotificationCampaign::AUDIENCE_ALL_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Test campagne',
        'body' => 'Corps',
        'status' => NotificationCampaign::STATUS_QUEUED,
    ]);

    $this->get(NotificationCampaignResource::getUrl('view', ['record' => $campaign]))->assertOk();
    $this->get(NotificationCampaignResource::getUrl('edit', ['record' => $campaign]))->assertForbidden();

    $scheduled = NotificationCampaign::query()->create([
        'sent_by' => $admin->id,
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_PUSH],
        'audience_type' => NotificationCampaign::AUDIENCE_ALL_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Campagne planifiée',
        'body' => 'Corps',
        'status' => NotificationCampaign::STATUS_SCHEDULED,
        'scheduled_at' => now()->addHour(),
    ]);

    $this->get(NotificationCampaignResource::getUrl('edit', ['record' => $scheduled]))->assertOk();
});
