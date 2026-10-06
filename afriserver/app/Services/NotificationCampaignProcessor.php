<?php

namespace App\Services;

use App\Models\NotificationCampaign;
use App\Models\NotificationDelivery;
use App\Models\TypeNotification;
use Illuminate\Support\Facades\DB;
use Throwable;

class NotificationCampaignProcessor
{
    public function __construct(
        private readonly CampaignAudienceResolver $audienceResolver,
        private readonly FcmNotificationService $fcm,
        private readonly CampaignMailService $mail,
    ) {}

    /**
     * @return array{campaigns_started: int, deliveries_processed: int, sent: int, failed: int, no_token: int, no_email: int}
     */
    public function process(int $limit = 50): array
    {
        $stats = [
            'campaigns_started' => 0,
            'deliveries_processed' => 0,
            'sent' => 0,
            'failed' => 0,
            'no_token' => 0,
            'no_email' => 0,
        ];

        $stats['campaigns_started'] = $this->promoteDueCampaigns() + $this->expandQueuedCampaigns();

        $deliveries = $this->claimPendingDeliveries($limit);

        foreach ($deliveries as $delivery) {
            $result = $this->processDelivery($delivery);
            $stats['deliveries_processed']++;
            $stats[$result] = ($stats[$result] ?? 0) + 1;
        }

        $this->completeFinishedCampaigns();

        return $stats;
    }

    private function promoteDueCampaigns(): int
    {
        return NotificationCampaign::query()
            ->where('status', NotificationCampaign::STATUS_SCHEDULED)
            ->whereNotNull('scheduled_at')
            ->where('scheduled_at', '<=', now())
            ->update(['status' => NotificationCampaign::STATUS_QUEUED]);
    }

    private function expandQueuedCampaigns(): int
    {
        $started = 0;

        $campaigns = NotificationCampaign::query()
            ->where('status', NotificationCampaign::STATUS_QUEUED)
            ->with(['users', 'devices', 'typeNotification'])
            ->orderBy('id')
            ->limit(10)
            ->get();

        foreach ($campaigns as $campaign) {
            DB::transaction(function () use ($campaign, &$started): void {
                $locked = NotificationCampaign::query()
                    ->whereKey($campaign->id)
                    ->where('status', NotificationCampaign::STATUS_QUEUED)
                    ->lockForUpdate()
                    ->first();

                if ($locked === null) {
                    return;
                }

                $users = $this->audienceResolver->resolveUsers($locked);
                $devicesByUser = $this->audienceResolver->resolveDevicesByUser($locked, $users);
                $rows = [];

                foreach ($users as $user) {
                    if ($locked->includesChannel(NotificationCampaign::CHANNEL_PUSH)) {
                        $rows[] = [
                            'notification_campaign_id' => $locked->id,
                            'user_id' => $user->id,
                            'channel' => NotificationDelivery::CHANNEL_PUSH,
                            'device_ids' => isset($devicesByUser[$user->id])
                                ? json_encode(array_values($devicesByUser[$user->id]))
                                : json_encode([]),
                            'status' => NotificationDelivery::STATUS_PENDING,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ];
                    }

                    if ($locked->includesChannel(NotificationCampaign::CHANNEL_EMAIL)) {
                        $rows[] = [
                            'notification_campaign_id' => $locked->id,
                            'user_id' => $user->id,
                            'channel' => NotificationDelivery::CHANNEL_EMAIL,
                            'device_ids' => null,
                            'status' => NotificationDelivery::STATUS_PENDING,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ];
                    }
                }

                foreach (array_chunk($rows, 500) as $chunk) {
                    NotificationDelivery::query()->insert($chunk);
                }

                $locked->update([
                    'status' => NotificationCampaign::STATUS_PROCESSING,
                    'stats' => [
                        'recipients' => $users->count(),
                        'deliveries' => count($rows),
                    ],
                ]);

                $started++;
            });
        }

        return $started;
    }

    /**
     * @return list<NotificationDelivery>
     */
    private function claimPendingDeliveries(int $limit): array
    {
        return DB::transaction(function () use ($limit): array {
            $ids = NotificationDelivery::query()
                ->where('status', NotificationDelivery::STATUS_PENDING)
                ->orderBy('id')
                ->limit($limit)
                ->lockForUpdate()
                ->pluck('id')
                ->all();

            if ($ids === []) {
                return [];
            }

            NotificationDelivery::query()
                ->whereIn('id', $ids)
                ->update([
                    'status' => NotificationDelivery::STATUS_PROCESSING,
                    'updated_at' => now(),
                ]);

            return NotificationDelivery::query()
                ->with(['user', 'campaign.typeNotification'])
                ->whereIn('id', $ids)
                ->get()
                ->all();
        });
    }

    private function processDelivery(NotificationDelivery $delivery): string
    {
        $campaign = $delivery->campaign;
        $user = $delivery->user;

        if ($campaign === null || $user === null) {
            $delivery->update([
                'status' => NotificationDelivery::STATUS_FAILED,
                'error_message' => 'Campagne ou utilisateur introuvable.',
                'processed_at' => now(),
            ]);

            return 'failed';
        }

        try {
            if ($delivery->channel === NotificationDelivery::CHANNEL_PUSH) {
                return $this->sendPush($delivery, $campaign, $user);
            }

            return $this->sendEmail($delivery, $campaign, $user);
        } catch (Throwable $e) {
            $delivery->update([
                'status' => NotificationDelivery::STATUS_FAILED,
                'error_message' => $e->getMessage(),
                'processed_at' => now(),
            ]);

            return 'failed';
        }
    }

    private function sendPush(NotificationDelivery $delivery, NotificationCampaign $campaign, $user): string
    {
        $deviceIds = $delivery->device_ids;
        if (is_array($deviceIds) && $deviceIds === []) {
            $delivery->update([
                'status' => NotificationDelivery::STATUS_NO_TOKEN,
                'processed_at' => now(),
            ]);

            return 'no_token';
        }

        $typeCode = $campaign->typeNotification?->code ?? TypeNotification::CODE_GENERAL;

        $report = $this->fcm->sendToUser(
            $user,
            $campaign->title,
            $campaign->body,
            [
                'type' => $typeCode,
                'campaign_id' => $campaign->id,
            ],
            is_array($deviceIds) ? array_map('intval', $deviceIds) : null,
        );

        if ($report === null) {
            $delivery->update([
                'status' => NotificationDelivery::STATUS_NO_TOKEN,
                'processed_at' => now(),
            ]);

            return 'no_token';
        }

        // Avant : on marquait "sent" même si Firebase refusait tous les tokens
        // (credentials prod absents / mauvais projet → succès=0, téléphone = rien).
        $successCount = $report->successes()->count();
        $failureCount = $report->failures()->count();

        if ($successCount === 0) {
            $firstError = null;
            foreach ($report->failures() as $failure) {
                $firstError = $failure->error()?->getMessage();
                break;
            }

            $delivery->update([
                'status' => NotificationDelivery::STATUS_FAILED,
                'error_message' => $firstError
                    ?? "FCM: 0 succès / {$failureCount} échec(s). Vérifier FIREBASE_CREDENTIALS sur le serveur.",
                'processed_at' => now(),
            ]);

            return 'failed';
        }

        $delivery->update([
            'status' => NotificationDelivery::STATUS_SENT,
            'error_message' => $failureCount > 0
                ? "Partiel: {$successCount} ok, {$failureCount} échec(s)."
                : null,
            'processed_at' => now(),
        ]);

        return 'sent';
    }

    private function sendEmail(NotificationDelivery $delivery, NotificationCampaign $campaign, $user): string
    {
        if (blank($user->email)) {
            $delivery->update([
                'status' => NotificationDelivery::STATUS_NO_EMAIL,
                'processed_at' => now(),
            ]);

            return 'no_email';
        }

        $subject = $campaign->email_subject ?: $campaign->title;
        $this->mail->send($user, $subject, $campaign->title, $campaign->body);

        $delivery->update([
            'status' => NotificationDelivery::STATUS_SENT,
            'processed_at' => now(),
        ]);

        return 'sent';
    }

    private function completeFinishedCampaigns(): void
    {
        $campaignIds = NotificationCampaign::query()
            ->where('status', NotificationCampaign::STATUS_PROCESSING)
            ->pluck('id');

        foreach ($campaignIds as $campaignId) {
            $remaining = NotificationDelivery::query()
                ->where('notification_campaign_id', $campaignId)
                ->whereIn('status', [
                    NotificationDelivery::STATUS_PENDING,
                    NotificationDelivery::STATUS_PROCESSING,
                ])
                ->exists();

            if ($remaining) {
                continue;
            }

            $counts = NotificationDelivery::query()
                ->where('notification_campaign_id', $campaignId)
                ->selectRaw('status, count(*) as aggregate')
                ->groupBy('status')
                ->pluck('aggregate', 'status')
                ->all();

            NotificationCampaign::query()->whereKey($campaignId)->update([
                'status' => NotificationCampaign::STATUS_COMPLETED,
                'stats' => $counts,
            ]);
        }
    }
}
