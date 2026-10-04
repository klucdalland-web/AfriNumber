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
function authenticatedUserForPlans(array $userAttributes = []): array
{
    $user = User::factory()->create(array_merge(['statut' => 'actif'], $userAttributes));

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-test-plans',
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

/**
 * @return array{free: Plan, basic: Plan, pro: Plan}
 */
function seedActivePlansCatalogue(): array
{
    $sms = Service::query()->create([
        'code' => 'sms_in',
        'label' => 'SMS entrants',
        'description' => 'SMS',
        'is_active' => true,
    ]);

    $free = Plan::query()->create([
        'code' => Plan::CODE_FREE,
        'label' => 'Free',
        'description' => 'Essai : 1 numéro virtuel pendant 14 jours',
        'price' => 0,
        'currency' => 'XOF',
        'duration_days' => 14,
        'max_numbers' => 1,
        'is_active' => true,
        'sort_order' => 0,
    ]);

    $basic = Plan::query()->create([
        'code' => Plan::CODE_BASIC,
        'label' => 'Basic',
        'description' => '1 numéro virtuel avec SMS entrants',
        'price' => 2500,
        'currency' => 'XOF',
        'duration_days' => 30,
        'max_numbers' => 1,
        'is_active' => true,
        'sort_order' => 1,
    ]);

    $pro = Plan::query()->create([
        'code' => Plan::CODE_PRO,
        'label' => 'Pro',
        'description' => 'Plusieurs numéros, SMS, appels et multi-pays',
        'price' => 10000,
        'currency' => 'XOF',
        'duration_days' => 30,
        'max_numbers' => 5,
        'is_active' => true,
        'sort_order' => 2,
    ]);

    $basic->services()->attach($sms->id, ['quota' => 100]);
    $pro->services()->attach($sms->id, ['quota' => 1000]);

    Plan::query()->create([
        'code' => 'legacy',
        'label' => 'Legacy',
        'description' => 'Inactif',
        'price' => 1,
        'currency' => 'XOF',
        'duration_days' => 30,
        'max_numbers' => 1,
        'is_active' => false,
        'sort_order' => 99,
    ]);

    return compact('free', 'basic', 'pro');
}

test('get plans returns the three active offers ordered with currently false by default', function (): void {
    seedActivePlansCatalogue();
    authenticatedUserForPlans();

    $response = $this->getJson('/api/v1/plans')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('message', 'Plans récupérés avec succès.')
        ->assertJsonPath('data.total', 3)
        ->assertJsonCount(3, 'data.plans');

    $plans = collect($response->json('data.plans'));

    expect($plans->pluck('code')->all())->toBe([
        Plan::CODE_FREE,
        Plan::CODE_BASIC,
        Plan::CODE_PRO,
    ])
        ->and($plans->every(fn (array $plan): bool => $plan['currently'] === false))->toBeTrue()
        ->and($plans->firstWhere('code', Plan::CODE_BASIC))
        ->toMatchArray([
            'label' => 'Basic',
            'price' => '2500.00',
            'currency' => 'XOF',
            'duration_days' => 30,
            'max_numbers' => 1,
            'currently' => false,
        ])
        ->and($plans->firstWhere('code', Plan::CODE_BASIC)['services'][0])
        ->toMatchArray([
            'code' => 'sms_in',
            'quota' => 100,
        ]);
});

test('get plans marks currently true on the active subscription plan', function (): void {
    $plans = seedActivePlansCatalogue();
    [$user] = authenticatedUserForPlans();

    $user->subscriptions()->create([
        'plan_id' => $plans['basic']->id,
        'status' => Subscription::STATUS_ACTIVE,
        'starts_at' => now()->subDay(),
        'ends_at' => now()->addDays(29),
        'auto_renew' => true,
    ]);

    $response = $this->getJson('/api/v1/plans')
        ->assertOk()
        ->assertJsonCount(3, 'data.plans');

    $payload = collect($response->json('data.plans'));

    expect($payload->firstWhere('code', Plan::CODE_FREE)['currently'])->toBeFalse()
        ->and($payload->firstWhere('code', Plan::CODE_BASIC)['currently'])->toBeTrue()
        ->and($payload->firstWhere('code', Plan::CODE_PRO)['currently'])->toBeFalse();
});

test('get plans ignores inactive or expired subscriptions for currently', function (): void {
    $plans = seedActivePlansCatalogue();
    [$user] = authenticatedUserForPlans();

    $user->subscriptions()->create([
        'plan_id' => $plans['pro']->id,
        'status' => Subscription::STATUS_EXPIRED,
        'starts_at' => now()->subDays(40),
        'ends_at' => now()->subDay(),
        'auto_renew' => false,
    ]);

    $response = $this->getJson('/api/v1/plans')
        ->assertOk()
        ->assertJsonCount(3, 'data.plans');

    expect(collect($response->json('data.plans'))->every(
        fn (array $plan): bool => $plan['currently'] === false
    ))->toBeTrue();
});

test('get plans requires authentication', function (): void {
    $this->getJson('/api/v1/plans')
        ->assertUnauthorized();
});
