<?php

use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\NotificationCampaign;
use App\Models\NotificationDelivery;
use App\Models\Platform;
use App\Models\SessionUser;
use App\Models\TypeNotification;
use App\Models\TypeUser;
use App\Models\User;
use App\Services\NotificationCampaignProcessor;
use Database\Seeders\TypeNotificationSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\MessageTarget;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Kreait\Firebase\Messaging\SendReport;
use Mockery\MockInterface;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    config([
        'services.internal.secret' => 'testing-internal-secret',
        'services.mail_api.secret' => 'mail-secret',
        'services.mail_api.url' => 'https://mail.test/api/send',
    ]);

    TypeUser::query()->updateOrCreate(
        ['code' => 'user'],
        ['label' => 'Utilisateur', 'description' => 'User', 'actif' => true],
    );

    $this->seed(TypeNotificationSeeder::class);
});

/**
 * @return array{0: User, 1: Device}
 */
function campaignUserWithDevice(string $token = 'campaign-token'): array
{
    $user = User::factory()->ofType('user')->create([
        'statut' => 'actif',
        'email' => 'user-campaign@example.com',
    ]);

    $platform = Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-campaign-001',
        'name' => 'Phone',
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

test('internal process endpoint rejects invalid signature', function (): void {
    $this->postJson('/api/v1/internal/process-notification-campaigns', ['limit' => 10])
        ->assertForbidden()
        ->assertJsonPath('statut', 'refuse');
});

test('internal process endpoint expands queued campaign and sends push', function (): void {
    [$user] = campaignUserWithDevice();
    $type = TypeNotification::query()->where('code', TypeNotification::CODE_ALERT)->firstOrFail();

    $campaign = NotificationCampaign::query()->create([
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_PUSH],
        'audience_type' => NotificationCampaign::AUDIENCE_ALL_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Alerte test',
        'body' => 'Corps de test',
        'status' => NotificationCampaign::STATUS_QUEUED,
    ]);

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->withArgs(function (CloudMessage $message, array $tokens): bool {
                return $tokens === ['campaign-token'];
            })
            ->andReturn(MulticastSendReport::withItems([
                SendReport::success(
                    MessageTarget::with(MessageTarget::TOKEN, 'campaign-token'),
                    ['name' => 'projects/x/messages/1'],
                ),
            ]));
    });

    $signature = hash_hmac('sha256', 'process-notification-campaigns', 'testing-internal-secret');

    $this->postJson('/api/v1/internal/process-notification-campaigns', ['limit' => 50], [
        'X-Signature' => $signature,
    ])
        ->assertOk()
        ->assertJsonPath('statut', 'ok')
        ->assertJsonPath('stats.campaigns_started', 1)
        ->assertJsonPath('stats.sent', 1);

    expect($campaign->fresh()->status)->toBe(NotificationCampaign::STATUS_COMPLETED)
        ->and(NotificationDelivery::query()->where('notification_campaign_id', $campaign->id)->count())->toBe(1)
        ->and(NotificationDelivery::query()->first()->status)->toBe(NotificationDelivery::STATUS_SENT)
        ->and(NotificationDelivery::query()->first()->user_id)->toBe($user->id);
});

test('processor promotes due scheduled campaigns then sends email', function (): void {
    $user = User::factory()->ofType('user')->create([
        'statut' => 'actif',
        'email' => 'mail-campaign@example.com',
    ]);

    $type = TypeNotification::query()->where('code', TypeNotification::CODE_GENERAL)->firstOrFail();

    $campaign = NotificationCampaign::query()->create([
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_EMAIL],
        'audience_type' => NotificationCampaign::AUDIENCE_SELECTED_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Hello',
        'body' => 'World',
        'email_subject' => 'Sujet custom',
        'scheduled_at' => now()->subMinute(),
        'status' => NotificationCampaign::STATUS_SCHEDULED,
    ]);
    $campaign->users()->attach($user->id);

    Http::fake([
        'https://mail.test/api/send' => Http::response(['ok' => true], 200),
    ]);

    $stats = app(NotificationCampaignProcessor::class)->process(20);

    expect($stats['campaigns_started'])->toBe(2)
        ->and($stats['sent'])->toBe(1)
        ->and($campaign->fresh()->status)->toBe(NotificationCampaign::STATUS_COMPLETED);

    Http::assertSent(function ($request) use ($user): bool {
        return $request->url() === 'https://mail.test/api/send'
            && $request['to'] === $user->email
            && $request['subject'] === 'Sujet custom';
    });
});

test('processor marks push delivery as no_token when user has no devices', function (): void {
    User::factory()->ofType('user')->create(['statut' => 'actif']);

    $type = TypeNotification::query()->where('code', TypeNotification::CODE_ALERT)->firstOrFail();

    $campaign = NotificationCampaign::query()->create([
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_PUSH],
        'audience_type' => NotificationCampaign::AUDIENCE_ALL_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Push',
        'body' => 'Sans device',
        'status' => NotificationCampaign::STATUS_QUEUED,
    ]);

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldNotReceive('sendMulticast');
    });

    app(NotificationCampaignProcessor::class)->process(20);

    expect(NotificationDelivery::query()->where('notification_campaign_id', $campaign->id)->value('status'))
        ->toBe(NotificationDelivery::STATUS_NO_TOKEN)
        ->and($campaign->fresh()->status)->toBe(NotificationCampaign::STATUS_COMPLETED);
});

test('processor marks push delivery as failed when FCM accepts zero tokens', function (): void {
    campaignUserWithDevice('bad-token');
    $type = TypeNotification::query()->where('code', TypeNotification::CODE_ALERT)->firstOrFail();

    $campaign = NotificationCampaign::query()->create([
        'type_notification_id' => $type->id,
        'channels' => [NotificationCampaign::CHANNEL_PUSH],
        'audience_type' => NotificationCampaign::AUDIENCE_ALL_USERS,
        'device_scope' => NotificationCampaign::DEVICE_SCOPE_ALL,
        'title' => 'Push',
        'body' => 'Token mort',
        'status' => NotificationCampaign::STATUS_QUEUED,
    ]);

    $this->mock(Messaging::class, function (MockInterface $mock): void {
        $mock->shouldReceive('sendMulticast')
            ->once()
            ->andReturn(MulticastSendReport::withItems([
                SendReport::failure(
                    MessageTarget::with(MessageTarget::TOKEN, 'bad-token'),
                    new \Kreait\Firebase\Exception\Messaging\NotFound('Requested entity was not found.'),
                ),
            ]));
    });

    $stats = app(NotificationCampaignProcessor::class)->process(20);

    expect($stats['failed'])->toBe(1)
        ->and(NotificationDelivery::query()->where('notification_campaign_id', $campaign->id)->value('status'))
        ->toBe(NotificationDelivery::STATUS_FAILED)
        ->and($campaign->fresh()->status)->toBe(NotificationCampaign::STATUS_COMPLETED);
});
