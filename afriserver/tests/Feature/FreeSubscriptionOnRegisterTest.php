<?php

use App\Models\Continent;
use App\Models\Organisation;
use App\Models\OtpVerification;
use App\Models\Pays;
use App\Models\Plan;
use App\Models\Subscription;
use App\Models\TypeUser;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);

    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));

    TypeUser::query()->updateOrCreate(
        ['code' => 'user'],
        [
            'label' => 'Utilisateur',
            'description' => 'Utilisateur standard',
            'actif' => true,
        ],
    );

    $organisation = Organisation::query()->create([
        'label' => 'AfriNumber Test',
        'description' => 'Org test',
        'actif' => true,
    ]);

    $continent = Continent::factory()->create();

    $this->pays = Pays::query()->create([
        'continent_id' => $continent->id,
        'organisation_id' => $organisation->id,
        'label' => 'Côte d\'Ivoire',
        'code' => 'CI',
        'indicatif' => '+225',
        'actif' => true,
    ]);

    Plan::query()->create([
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
});

test('registering a user assigns the free subscription after otp verification', function (): void {
    $register = $this->postJson('/api/v1/auth/register', [
        'contrie_id' => $this->pays->id,
        'name' => 'Dupont',
        'first_name' => 'Jean',
        'email' => 'jean.free@example.com',
        'phone_number' => '0700000001',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'platform' => 'android',
        'device_id' => 'device-free-001',
        'device_name' => 'Pixel',
        'device_model' => 'Pixel 8',
        'os_version' => '14',
        'app_version' => '1.0.0',
        'fcm_token' => 'fcm-free-token',
    ]);

    $register->assertOk()->assertJsonPath('success', true);

    OtpVerification::query()
        ->where('email', 'jean.free@example.com')
        ->where('purpose', 'register')
        ->update(['code' => Hash::make('123456')]);

    $verify = $this->postJson('/api/v1/auth/verify-otp', [
        'email' => 'jean.free@example.com',
        'purpose' => 'register',
        'code' => '123456',
    ]);

    $verify->assertCreated()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.email', 'jean.free@example.com')
        ->assertJsonPath('data.user.subscription.status', Subscription::STATUS_ACTIVE)
        ->assertJsonPath('data.user.subscription.plan.code', Plan::CODE_FREE)
        ->assertJsonPath('data.user.subscription.auto_renew', false);

    $user = User::query()->where('email', 'jean.free@example.com')->first();

    expect($user)->not->toBeNull();

    $this->assertDatabaseHas('subscriptions', [
        'user_id' => $user->id,
        'status' => Subscription::STATUS_ACTIVE,
        'auto_renew' => false,
    ]);

    $subscription = $user->activeSubscription();

    expect($subscription)->not->toBeNull()
        ->and($subscription->plan?->code)->toBe(Plan::CODE_FREE)
        ->and($subscription->ends_at?->greaterThan($subscription->starts_at))->toBeTrue();

    $accessToken = $verify->json('data.access_token');
    $deviceId = 'device-free-001';

    $this->withToken($accessToken)
        ->withHeader('X-Device-Id', $deviceId)
        ->getJson('/api/v1/user')
        ->assertOk()
        ->assertJsonPath('data.user.subscription.plan.code', Plan::CODE_FREE)
        ->assertJsonPath('data.user.subscription.status', Subscription::STATUS_ACTIVE);

    $this->withToken($accessToken)
        ->withHeader('X-Device-Id', $deviceId)
        ->getJson('/api/v1/auth/me')
        ->assertOk()
        ->assertJsonPath('data.user.subscription.plan.code', Plan::CODE_FREE);
});
