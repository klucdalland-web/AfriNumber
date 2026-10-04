<?php

use App\Models\Device;
use App\Models\Plan;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\Subscription;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));
});

/**
 * @return array{0: User, 1: string}
 */
function authenticatedUserWithDevice(array $userAttributes = []): array
{
    $user = User::factory()->create(array_merge(['statut' => 'actif'], $userAttributes));

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-test-user-sub',
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

test('get user returns the current subscription with plan', function (): void {
    $plan = Plan::query()->create([
        'code' => Plan::CODE_FREE,
        'label' => 'Free',
        'description' => 'Essai',
        'price' => 0,
        'currency' => 'XOF',
        'duration_days' => 14,
        'max_numbers' => 1,
        'is_active' => true,
        'sort_order' => 0,
    ]);

    [$user] = authenticatedUserWithDevice();

    $subscription = $user->subscriptions()->create([
        'plan_id' => $plan->id,
        'status' => Subscription::STATUS_ACTIVE,
        'starts_at' => now()->subDay(),
        'ends_at' => now()->addDays(13),
        'auto_renew' => false,
    ]);

    $this->getJson('/api/v1/user')
        ->assertOk()
        ->assertJsonPath('data.user.email', $user->email)
        ->assertJsonPath('data.user.subscription.id', $subscription->id)
        ->assertJsonPath('data.user.subscription.status', Subscription::STATUS_ACTIVE)
        ->assertJsonPath('data.user.subscription.plan.code', Plan::CODE_FREE)
        ->assertJsonPath('data.user.subscription.plan.label', 'Free')
        ->assertJsonPath('data.user.subscription.auto_renew', false);
});

test('get user returns null subscription when none is active', function (): void {
    [$user] = authenticatedUserWithDevice();

    $this->getJson('/api/v1/user')
        ->assertOk()
        ->assertJsonPath('data.user.email', $user->email)
        ->assertJsonPath('data.user.subscription', null);
});
