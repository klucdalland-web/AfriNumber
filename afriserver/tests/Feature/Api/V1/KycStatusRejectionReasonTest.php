<?php

use App\Models\Device;
use App\Models\Platform;
use App\Models\Profile;
use App\Models\SessionUser;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));
});

/**
 * @return array{0: User, 1: Profile}
 */
function authenticatedUserWithRejectedKyc(): array
{
    $user = User::factory()->create([
        'statut' => 'actif',
        'status_valide' => 'non_valide',
    ]);

    $profile = Profile::query()->create([
        'user_id' => $user->id,
        'status' => Profile::STATUS_REJETE,
        'rejection_reason' => 'Selfie flou',
    ]);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-kyc-status-001',
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

    return [$user, $profile];
}

test('kyc status endpoint returns rejection_reason for rejected profiles', function (): void {
    [, $profile] = authenticatedUserWithRejectedKyc();

    $this->getJson('/api/v1/verifier/status')
        ->assertOk()
        ->assertJsonPath('statut', Profile::STATUS_REJETE)
        ->assertJsonPath('profile_id', $profile->id)
        ->assertJsonPath('rejection_reason', 'Selfie flou')
        ->assertJsonPath('status_valide', 'non_valide');
});

test('kyc status by id returns rejection_reason', function (): void {
    [, $profile] = authenticatedUserWithRejectedKyc();

    $this->getJson('/api/v1/verifier/status/'.$profile->id)
        ->assertOk()
        ->assertJsonPath('rejection_reason', 'Selfie flou');
});
