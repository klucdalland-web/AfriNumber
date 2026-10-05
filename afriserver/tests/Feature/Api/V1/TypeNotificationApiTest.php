<?php

use App\Models\Device;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\TypeNotification;
use App\Models\User;
use Database\Seeders\TypeNotificationSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));
});

/**
 * @return array{0: User, 1: string}
 */
function authenticatedUserForTypeNotifications(): array
{
    $user = User::factory()->create(['statut' => 'actif']);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-type-notif',
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

test('unauthenticated users receive 401 when listing type notifications', function (): void {
    $this->getJson('/api/v1/type-notifications')
        ->assertUnauthorized();
});

test('lists active type notifications ordered by sort_order', function (): void {
    authenticatedUserForTypeNotifications();
    $this->seed(TypeNotificationSeeder::class);

    TypeNotification::query()->create([
        'code' => 'inactive_type',
        'label' => 'Inactif',
        'description' => 'Ne doit pas apparaître',
        'actif' => false,
        'sort_order' => 0,
    ]);

    $response = $this->getJson('/api/v1/type-notifications')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.total', 7);

    $codes = collect($response->json('data.types'))->pluck('code')->all();

    expect($codes)->toBe([
        TypeNotification::CODE_KYC_APPROVED,
        TypeNotification::CODE_KYC_REJECTED,
        TypeNotification::CODE_KYC_MANUAL_REVIEW,
        TypeNotification::CODE_GENERAL,
        TypeNotification::CODE_ALERT,
        TypeNotification::CODE_SUBSCRIPTION,
        TypeNotification::CODE_PAYMENT,
    ])
        ->and($codes)->not->toContain('inactive_type');
});

test('shows a single active type notification', function (): void {
    authenticatedUserForTypeNotifications();
    $this->seed(TypeNotificationSeeder::class);

    $type = TypeNotification::query()
        ->where('code', TypeNotification::CODE_ALERT)
        ->firstOrFail();

    $this->getJson('/api/v1/type-notifications/'.$type->id)
        ->assertOk()
        ->assertJsonPath('data.type.code', TypeNotification::CODE_ALERT)
        ->assertJsonPath('data.type.label', 'Alerte');
});

test('returns 404 for an inactive type notification', function (): void {
    authenticatedUserForTypeNotifications();

    $type = TypeNotification::query()->create([
        'code' => 'hidden_type',
        'label' => 'Caché',
        'description' => null,
        'actif' => false,
        'sort_order' => 99,
    ]);

    $this->getJson('/api/v1/type-notifications/'.$type->id)
        ->assertNotFound();
});
