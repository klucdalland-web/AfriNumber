<?php

use App\Models\Device;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\TypeNotification;
use App\Models\User;
use App\Models\UserNotification;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));
});

/**
 * @return array{0: User, 1: string}
 */
function authenticatedUserForNotifications(string $deviceId = 'device-notif-001'): array
{
    $user = User::factory()->create(['statut' => 'actif']);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => $deviceId,
        'name' => 'Test phone',
        'model' => 'Pixel',
        'os_version' => '14',
        'actif' => true,
        'last_used_at' => now(),
    ]);

    SessionUser::query()->create([
        'user_id' => $user->id,
        'device_id' => $device->id,
        'is_active' => true,
    ]);

    $token = $user->createToken('test-access', ['access-api'])->plainTextToken;

    test()->withToken($token)
        ->withHeader('X-Device-Id', $device->identifier);

    return [$user, $token];
}

test('unauthenticated users receive 401 on notification routes', function (): void {
    $this->getJson('/api/v1/notifications')->assertUnauthorized();
    $this->getJson('/api/v1/notifications/unread-count')->assertUnauthorized();
    $this->postJson('/api/v1/notifications/read-all')->assertUnauthorized();
});

test('lists only the authenticated user notifications', function (): void {
    [$user] = authenticatedUserForNotifications();
    $other = User::factory()->create(['statut' => 'actif']);

    UserNotification::createForUser($user, 'Mine', 'Body A');
    UserNotification::createForUser($other, 'Other', 'Body B');

    $response = $this->getJson('/api/v1/notifications')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.meta.total', 1);

    expect($response->json('data.notifications.0.title'))->toBe('Mine')
        ->and($response->json('data.notifications'))->toHaveCount(1);
});

test('filters unread notifications and returns unread_count', function (): void {
    [$user] = authenticatedUserForNotifications();

    UserNotification::createForUser($user, 'Unread', 'A');
    $read = UserNotification::createForUser($user, 'Read', 'B');
    $read->markAsRead();

    $this->getJson('/api/v1/notifications?unread=1')
        ->assertOk()
        ->assertJsonPath('data.meta.total', 1)
        ->assertJsonPath('data.meta.unread_count', 1)
        ->assertJsonPath('data.notifications.0.title', 'Unread');

    $this->getJson('/api/v1/notifications/unread-count')
        ->assertOk()
        ->assertJsonPath('data.unread_count', 1);
});

test('shows a notification owned by the user', function (): void {
    [$user] = authenticatedUserForNotifications();

    $type = TypeNotification::query()->create([
        'code' => 'alert_test',
        'label' => 'Alerte',
        'description' => null,
        'actif' => true,
        'sort_order' => 1,
    ]);

    $item = UserNotification::createForUser(
        $user,
        'Hello',
        'World',
        $type->id,
        ['deep_link' => '/home'],
    );

    $this->getJson('/api/v1/notifications/'.$item->id)
        ->assertOk()
        ->assertJsonPath('data.notification.title', 'Hello')
        ->assertJsonPath('data.notification.is_read', false)
        ->assertJsonPath('data.notification.type.code', 'alert_test')
        ->assertJsonPath('data.notification.data.deep_link', '/home');
});

test('cannot access another user notification', function (): void {
    authenticatedUserForNotifications();
    $other = User::factory()->create(['statut' => 'actif']);
    $item = UserNotification::createForUser($other, 'Secret', 'Nope');

    $this->getJson('/api/v1/notifications/'.$item->id)
        ->assertNotFound()
        ->assertJsonPath('success', false);

    $this->postJson('/api/v1/notifications/'.$item->id.'/read')
        ->assertNotFound();

    $this->deleteJson('/api/v1/notifications/'.$item->id)
        ->assertNotFound();
});

test('marks one notification as read', function (): void {
    [$user] = authenticatedUserForNotifications();
    $item = UserNotification::createForUser($user, 'To read', 'Body');

    $this->postJson('/api/v1/notifications/'.$item->id.'/read')
        ->assertOk()
        ->assertJsonPath('data.notification.is_read', true);

    expect($item->fresh()->read_at)->not->toBeNull();
});

test('marks all notifications as read', function (): void {
    [$user] = authenticatedUserForNotifications();
    UserNotification::createForUser($user, 'A', '1');
    UserNotification::createForUser($user, 'B', '2');

    $this->postJson('/api/v1/notifications/read-all')
        ->assertOk()
        ->assertJsonPath('data.updated', 2)
        ->assertJsonPath('data.unread_count', 0);

    expect(
        UserNotification::query()->forUser($user->id)->unread()->count()
    )->toBe(0);
});

test('deletes own notification', function (): void {
    [$user] = authenticatedUserForNotifications();
    $item = UserNotification::createForUser($user, 'Bye', 'Body');

    $this->deleteJson('/api/v1/notifications/'.$item->id)
        ->assertOk()
        ->assertJsonPath('success', true);

    expect(UserNotification::query()->find($item->id))->toBeNull();
});
