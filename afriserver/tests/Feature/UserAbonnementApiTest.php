<?php

use App\Models\Device;
use App\Models\Plan;
use App\Models\Platform;
use App\Models\Service;
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
function authenticatedUserForAbonnement(array $userAttributes = []): array
{
    $user = User::factory()->create(array_merge(['statut' => 'actif'], $userAttributes));

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-test-abonnement',
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

test('get abonnement returns the active subscription with full plan and services', function (): void {
    $plan = Plan::query()->create([
        'code' => Plan::CODE_FREE,
        'label' => 'Free',
        'description' => 'Essai gratuit',
        'price' => 0,
        'currency' => 'XOF',
        'duration_days' => 14,
        'max_numbers' => 1,
        'is_active' => true,
        'sort_order' => 0,
    ]);

    $sms = Service::query()->create([
        'code' => 'sms',
        'label' => 'SMS',
        'description' => 'Envoi SMS',
        'is_active' => true,
    ]);

    $voice = Service::query()->create([
        'code' => 'voice',
        'label' => 'Voice',
        'description' => 'Appels',
        'is_active' => true,
    ]);

    $plan->services()->attach([
        $sms->id => ['quota' => 10],
        $voice->id => ['quota' => 5],
    ]);

    [$user] = authenticatedUserForAbonnement();

    $subscription = $user->subscriptions()->create([
        'plan_id' => $plan->id,
        'status' => Subscription::STATUS_ACTIVE,
        'starts_at' => now()->subDay(),
        'ends_at' => now()->addDays(13),
        'auto_renew' => false,
    ]);

    $this->getJson('/api/v1/abonnement')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.abonnement.id', $subscription->id)
        ->assertJsonPath('data.abonnement.status', Subscription::STATUS_ACTIVE)
        ->assertJsonPath('data.abonnement.is_currently_active', true)
        ->assertJsonPath('data.abonnement.auto_renew', false)
        ->assertJsonPath('data.abonnement.plan.code', Plan::CODE_FREE)
        ->assertJsonPath('data.abonnement.plan.label', 'Free')
        ->assertJsonPath('data.abonnement.plan.description', 'Essai gratuit')
        ->assertJsonPath('data.abonnement.plan.price', '0.00')
        ->assertJsonPath('data.abonnement.plan.currency', 'XOF')
        ->assertJsonPath('data.abonnement.plan.duration_days', 14)
        ->assertJsonPath('data.abonnement.plan.max_numbers', 1)
        ->assertJsonPath('data.abonnement.plan.services.0.code', 'sms')
        ->assertJsonPath('data.abonnement.plan.services.0.quota', 10)
        ->assertJsonPath('data.abonnement.plan.services.1.code', 'voice')
        ->assertJsonPath('data.abonnement.plan.services.1.quota', 5);
});

test('get abonnement returns null when no active subscription', function (): void {
    authenticatedUserForAbonnement();

    $this->getJson('/api/v1/abonnement')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.abonnement', null);
});

test('get abonnement requires authentication', function (): void {
    $this->getJson('/api/v1/abonnement')
        ->assertUnauthorized();
});
