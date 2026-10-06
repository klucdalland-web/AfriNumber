<?php

namespace App\Services;

use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\User;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Kreait\Firebase\Messaging\Notification;
use Throwable;

class FcmNotificationService
{
    public function __construct(
        private readonly Messaging $messaging,
    ) {}

    /**
     * Envoie une notification push aux appareils actifs de l'utilisateur.
     *
     * @param  array<string, scalar|null>  $data
     * @param  list<int>|null  $deviceIds  Si fourni, limite l'envoi à ces devices.
     */
    public function sendToUser(
        User $user,
        string $title,
        string $body,
        array $data = [],
        ?array $deviceIds = null,
    ): ?MulticastSendReport {
        $deviceQuery = Device::query()
            ->where('user_id', $user->id)
            ->where('actif', true);

        if ($deviceIds !== null) {
            $deviceQuery->whereIn('id', $deviceIds);
        }

        $tokens = DeviceTokenFcm::query()
            ->where('actif', true)
            ->whereIn('device_id', $deviceQuery->select('id'))
            ->pluck('token')
            ->filter()
            ->unique()
            ->values()
            ->all();

        if ($tokens === []) {
            return null;
        }

        $stringData = [];
        foreach ($data as $key => $value) {
            if ($value === null) {
                continue;
            }

            $stringData[(string) $key] = is_bool($value)
                ? ($value ? '1' : '0')
                : (string) $value;
        }

        $message = CloudMessage::new()
            ->withNotification(Notification::create($title, $body));

        if ($stringData !== []) {
            $message = $message->withData($stringData);
        }

        try {
            $report = $this->messaging->sendMulticast($message, $tokens);
        } catch (Throwable $e) {
            Log::error('Échec envoi FCM multicast', [
                'user_id' => $user->id,
                'token_count' => count($tokens),
                'error' => $e->getMessage(),
            ]);

            throw $e;
        }

        Log::info('FCM multicast terminé', [
            'user_id' => $user->id,
            'token_count' => count($tokens),
            'success' => $report->successes()->count(),
            'failure' => $report->failures()->count(),
            'invalid' => count($report->invalidTokens()),
            'unknown' => count($report->unknownTokens()),
        ]);

        foreach ($report->failures() as $failure) {
            Log::warning('FCM token refusé', [
                'user_id' => $user->id,
                'error' => $failure->error()?->getMessage(),
            ]);
        }

        $this->deactivateInvalidTokens($report);

        return $report;
    }

    private function deactivateInvalidTokens(MulticastSendReport $report): void
    {
        $invalidTokens = array_values(array_unique(array_merge(
            $report->invalidTokens(),
            $report->unknownTokens(),
        )));

        if ($invalidTokens === []) {
            return;
        }

        DeviceTokenFcm::query()
            ->whereIn('token', $invalidTokens)
            ->update(['actif' => false]);
    }
}
