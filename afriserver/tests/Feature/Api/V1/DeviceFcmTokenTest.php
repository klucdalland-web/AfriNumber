<?php

use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));
});

/**
 * @return array{0: User, 1: Device, 2: string}
 */
function fcmAuthenticatedUserWithDevice(string $identifier = 'device-fcm-001'): array
{
    $user = User::factory()->create(['statut' => 'actif']);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => $identifier,
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

    return [$user, $device, $token];
}

test('unauthenticated users receive 401 when updating fcm token', function (): void {
    $this->postJson('/api/v1/devices/fcm-token', [
        'device_id' => 'device-fcm-001',
        'token' => 'new-fcm-token',
    ])->assertUnauthorized();
});

test('rejects missing device_id and token with validation errors', function (): void {
    fcmAuthenticatedUserWithDevice();

    $this->postJson('/api/v1/devices/fcm-token', [])
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['device_id', 'token']);
});

test('returns 404 when the device does not belong to the authenticated user', function (): void {
    [, $device] = fcmAuthenticatedUserWithDevice();

    $otherUser = User::factory()->create(['statut' => 'actif']);
    $otherDevice = Device::query()->create([
        'user_id' => $otherUser->id,
        'platform_id' => $device->platform_id,
        'identifier' => 'other-user-device',
        'name' => 'Other phone',
        'model' => 'Pixel',
        'os_version' => '14',
        'actif' => true,
        'last_used_at' => now(),
    ]);

    $this->postJson('/api/v1/devices/fcm-token', [
        'device_id' => $otherDevice->identifier,
        'token' => 'stolen-token',
    ])
        ->assertNotFound()
        ->assertJsonPath('success', false);
});

test('returns 404 when the device is inactive', function (): void {
    [$user, $currentDevice] = fcmAuthenticatedUserWithDevice('device-current-fcm');

    $inactiveDevice = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $currentDevice->platform_id,
        'identifier' => 'device-inactive-fcm',
        'name' => 'Inactive phone',
        'model' => 'Pixel',
        'os_version' => '14',
        'actif' => false,
        'last_used_at' => now(),
    ]);

    $this->postJson('/api/v1/devices/fcm-token', [
        'device_id' => $inactiveDevice->identifier,
        'token' => 'new-fcm-token',
    ])->assertNotFound();
});

test('creates the fcm token for an active device', function (): void {
    [, $device] = fcmAuthenticatedUserWithDevice('device-create-fcm');

    $this->postJson('/api/v1/devices/fcm-token', [
        'device_id' => $device->identifier,
        'token' => 'fresh-fcm-token',
    ])
        ->assertOk()
        ->assertJsonPath('success', true);

    $this->assertDatabaseHas('device_token_fcms', [
        'device_id' => $device->id,
        'token' => 'fresh-fcm-token',
        'actif' => true,
    ]);
});

test('updates an existing fcm token and reactivates it', function (): void {
    [, $device] = fcmAuthenticatedUserWithDevice('device-update-fcm');

    DeviceTokenFcm::query()->create([
        'device_id' => $device->id,
        'token' => 'old-fcm-token',
        'actif' => false,
    ]);

    $this->postJson('/api/v1/devices/fcm-token', [
        'device_id' => $device->identifier,
        'token' => 'rotated-fcm-token',
    ])->assertOk();

    $this->assertDatabaseHas('device_token_fcms', [
        'device_id' => $device->id,
        'token' => 'rotated-fcm-token',
        'actif' => true,
    ]);

    $this->assertDatabaseMissing('device_token_fcms', [
        'device_id' => $device->id,
        'token' => 'old-fcm-token',
    ]);
});

test('moves a token already attached to another device onto the current device', function (): void {
    [$user, $device] = fcmAuthenticatedUserWithDevice('device-token-owner');

    $otherDevice = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $device->platform_id,
        'identifier' => 'device-token-previous',
        'name' => 'Old phone',
        'model' => 'Pixel',
        'os_version' => '13',
        'actif' => true,
        'last_used_at' => now(),
    ]);

    SessionUser::query()->create([
        'user_id' => $user->id,
        'device_id' => $otherDevice->id,
        'is_active' => true,
    ]);

    DeviceTokenFcm::query()->create([
        'device_id' => $otherDevice->id,
        'token' => 'shared-fcm-token',
        'actif' => true,
    ]);

    $this->postJson('/api/v1/devices/fcm-token', [
        'device_id' => $device->identifier,
        'token' => 'shared-fcm-token',
    ])->assertOk();

    $this->assertDatabaseHas('device_token_fcms', [
        'device_id' => $device->id,
        'token' => 'shared-fcm-token',
        'actif' => true,
    ]);

    $this->assertDatabaseMissing('device_token_fcms', [
        'device_id' => $otherDevice->id,
        'token' => 'shared-fcm-token',
    ]);
});
