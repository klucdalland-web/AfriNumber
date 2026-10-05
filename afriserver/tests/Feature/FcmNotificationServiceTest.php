<?php

use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\User;
use App\Services\FcmNotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\Messaging\NotFound;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\MessageTarget;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Kreait\Firebase\Messaging\SendReport;
use Mockery\MockInterface;

uses(RefreshDatabase::class);

/**
 * @return array{0: User, 1: Device}
 */
function fcmServiceUserWithToken(string $token = 'valid-fcm-token'): array
{
    $user = User::factory()->create(['statut' => 'actif']);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-fcm-service-001',
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
        'token' => $token,
        'actif' => true,
    ]);

    return [$user, $device];
}

test('returns null when the user has no active fcm tokens', function (): void {
    $user = User::factory()->create(['statut' => 'actif']);

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldNotReceive('sendMulticast');
    });

    $report = app(FcmNotificationService::class)->sendToUser($user, 'Titre', 'Corps');

    expect($report)->toBeNull();
});

test('sends a multicast notification to active user tokens', function (): void {
    [$user] = fcmServiceUserWithToken('token-a');

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->withArgs(function (CloudMessage $message, array $tokens): bool {
                return $tokens === ['token-a'];
            })
            ->andReturn(MulticastSendReport::withItems([
                SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'token-a'), ['name' => 'projects/x/messages/1']),
            ]));
    });

    $report = app(FcmNotificationService::class)->sendToUser(
        $user,
        'KYC approuvé',
        'Votre vérification est terminée.',
        ['type' => 'kyc_approved', 'profile_id' => 42],
    );

    expect($report)->not->toBeNull()
        ->and($report->successes()->count())->toBe(1);
});

test('deactivates unknown and invalid tokens after send', function (): void {
    [$user, $device] = fcmServiceUserWithToken('dead-token');

    $otherDevice = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $device->platform_id,
        'identifier' => 'device-fcm-service-002',
        'name' => 'Second phone',
        'model' => 'Pixel',
        'os_version' => '14',
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
        'token' => 'alive-token',
        'actif' => true,
    ]);

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->andReturn(MulticastSendReport::withItems([
                SendReport::failure(
                    MessageTarget::with(MessageTarget::TOKEN, 'dead-token'),
                    NotFound::becauseTokenNotFound('dead-token'),
                ),
                SendReport::success(
                    MessageTarget::with(MessageTarget::TOKEN, 'alive-token'),
                    ['name' => 'projects/x/messages/2'],
                ),
            ]));
    });

    app(FcmNotificationService::class)->sendToUser($user, 'Titre', 'Corps');

    $this->assertDatabaseHas('device_token_fcms', [
        'device_id' => $device->id,
        'token' => 'dead-token',
        'actif' => false,
    ]);

    $this->assertDatabaseHas('device_token_fcms', [
        'device_id' => $otherDevice->id,
        'token' => 'alive-token',
        'actif' => true,
    ]);
});

test('ignores inactive devices when collecting tokens', function (): void {
    [$user, $device] = fcmServiceUserWithToken('inactive-device-token');

    $device->update(['actif' => false]);

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldNotReceive('sendMulticast');
    });

    $report = app(FcmNotificationService::class)->sendToUser($user, 'Titre', 'Corps');

    expect($report)->toBeNull();
});
