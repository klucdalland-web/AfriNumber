<?php

use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\Platform;
use App\Models\Profile;
use App\Models\SessionUser;
use App\Models\TypeNotification;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\MessageTarget;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Kreait\Firebase\Messaging\SendReport;
use Mockery\MockInterface;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    config(['services.internal.secret' => 'testing-internal-secret']);
});

/**
 * @return array{0: User, 1: Profile}
 */
function kycProfileAwaitingVerdict(): array
{
    $user = User::factory()->create(['statut' => 'actif']);

    $profile = Profile::query()->create([
        'user_id' => $user->id,
        'status' => 'en_cours_de_verification',
    ]);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-kyc-fcm-001',
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

    DeviceTokenFcm::query()->create([
        'device_id' => $device->id,
        'token' => 'kyc-fcm-token',
        'actif' => true,
    ]);

    return [$user, $profile];
}

/**
 * @return array<string, string>
 */
function kycSignedHeaders(string $profileId): array
{
    $secret = (string) config('services.internal.secret');

    return [
        'X-Signature' => hash_hmac('sha256', $profileId, $secret),
    ];
}

/**
 * @return array<string, string>
 */
function kycMessageData(CloudMessage $message): array
{
    /** @var array{data?: array<string, string>} $payload */
    $payload = $message->jsonSerialize();

    return $payload['data'] ?? [];
}

test('approved verdict sends fcm with kyc_approved type', function (): void {
    [, $profile] = kycProfileAwaitingVerdict();

    $this->mock(Messaging::class, function (MockInterface $mock) use ($profile): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->withArgs(function (CloudMessage $message, array $tokens) use ($profile): bool {
                $data = kycMessageData($message);

                return $tokens === ['kyc-fcm-token']
                    && ($data['type'] ?? null) === TypeNotification::CODE_KYC_APPROVED
                    && ($data['profile_id'] ?? null) === (string) $profile->id;
            })
            ->andReturn(MulticastSendReport::withItems([
                SendReport::success(
                    MessageTarget::with(MessageTarget::TOKEN, 'kyc-fcm-token'),
                    ['name' => 'projects/x/messages/1'],
                ),
            ]));
    });

    $this->postJson('/api/v1/n8n/kyc-callback', [
        'profile_id' => $profile->id,
        'kyc_status' => 'approved',
        'title' => 'OK',
        'message' => 'Votre identité est validée.',
    ], kycSignedHeaders($profile->id))
        ->assertOk()
        ->assertJsonPath('statut', 'succes');

    $this->assertDatabaseHas('profiles', [
        'id' => $profile->id,
        'status' => 'approuve',
    ]);
});

test('rejected verdict sends fcm with kyc_rejected type and reason', function (): void {
    [, $profile] = kycProfileAwaitingVerdict();

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->withArgs(function (CloudMessage $message, array $tokens): bool {
                $data = kycMessageData($message);

                return ($data['type'] ?? null) === TypeNotification::CODE_KYC_REJECTED
                    && ($data['reason'] ?? null) === 'Document illisible'
                    && $tokens === ['kyc-fcm-token'];
            })
            ->andReturn(MulticastSendReport::withItems([
                SendReport::success(
                    MessageTarget::with(MessageTarget::TOKEN, 'kyc-fcm-token'),
                    ['name' => 'projects/x/messages/2'],
                ),
            ]));
    });

    $this->postJson('/api/v1/n8n/kyc-callback', [
        'profile_id' => $profile->id,
        'kyc_status' => 'rejected',
        'reason' => 'Document illisible',
        'message' => 'Merci de renvoyer une photo plus nette.',
    ], kycSignedHeaders($profile->id))
        ->assertOk()
        ->assertJsonPath('statut', 'succes');

    $this->assertDatabaseHas('profiles', [
        'id' => $profile->id,
        'status' => 'rejete',
    ]);
});

test('manual_review verdict sends fcm with kyc_manual_review type', function (): void {
    [, $profile] = kycProfileAwaitingVerdict();

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->withArgs(function (CloudMessage $message): bool {
                $data = kycMessageData($message);

                return ($data['type'] ?? null) === TypeNotification::CODE_KYC_MANUAL_REVIEW;
            })
            ->andReturn(MulticastSendReport::withItems([
                SendReport::success(
                    MessageTarget::with(MessageTarget::TOKEN, 'kyc-fcm-token'),
                    ['name' => 'projects/x/messages/3'],
                ),
            ]));
    });

    $this->postJson('/api/v1/n8n/kyc-callback', [
        'profile_id' => $profile->id,
        'kyc_status' => 'manual_review',
        'reason' => 'Selfie ambigu',
    ], kycSignedHeaders($profile->id))
        ->assertOk()
        ->assertJsonPath('statut', 'succes');

    $this->assertDatabaseHas('profiles', [
        'id' => $profile->id,
        'status' => 'en_cours_de_verification',
    ]);
});

test('kyc verdict still succeeds when fcm sending fails', function (): void {
    [, $profile] = kycProfileAwaitingVerdict();

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->andThrow(new RuntimeException('Firebase down'));
    });

    $this->postJson('/api/v1/n8n/kyc-callback', [
        'profile_id' => $profile->id,
        'kyc_status' => 'approved',
    ], kycSignedHeaders($profile->id))
        ->assertOk()
        ->assertJsonPath('statut', 'succes');

    $this->assertDatabaseHas('profiles', [
        'id' => $profile->id,
        'status' => 'approuve',
    ]);
});

test('rejects kyc callback with invalid signature', function (): void {
    [, $profile] = kycProfileAwaitingVerdict();

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldNotReceive('sendMulticast');
    });

    $this->postJson('/api/v1/n8n/kyc-callback', [
        'profile_id' => $profile->id,
        'kyc_status' => 'approved',
    ], ['X-Signature' => 'invalid'])
        ->assertForbidden();
});
