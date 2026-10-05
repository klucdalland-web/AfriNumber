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
     * Envoie une notification push à tous les appareils actifs de l'utilisateur.
     *
     * @param  array<string, scalar|null>  $data
     */
    public function sendToUser(User $user, string $title, string $body, array $data = []): ?MulticastSendReport
    {
        $tokens = DeviceTokenFcm::query()
            ->where('actif', true)
            ->whereIn(
                'device_id',
                Device::query()
                    ->where('user_id', $user->id)
                    ->where('actif', true)
                    ->select('id')
            )
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
