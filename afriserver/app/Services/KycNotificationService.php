<?php

namespace App\Services;

use App\Models\Profile;
use App\Models\TypeNotification;
use App\Models\User;
use App\Models\UserNotification;
use Illuminate\Support\Facades\Log;
use Throwable;

/**
 * Notification inbox + push FCM pour les verdicts KYC (n8n ou admin).
 */
class KycNotificationService
{
    public function __construct(
        private readonly FcmNotificationService $fcm,
    ) {}

    /**
     * Persiste une notification in-app puis tente le push FCM.
     * L'échec FCM ne doit jamais faire échouer le verdict déjà persisté.
     *
     * @param  array<string, scalar|null>  $data
     */
    public function notifyVerdict(
        User $user,
        Profile $profile,
        string $typeCode,
        string $title,
        string $body,
        array $data = [],
    ): void {
        $typeId = TypeNotification::query()
            ->where('code', $typeCode)
            ->where('actif', true)
            ->value('id');

        $payload = array_merge([
            'type' => $typeCode,
            'profile_id' => $profile->id,
        ], $data);

        try {
            UserNotification::createForUser(
                $user,
                $title,
                $body,
                $typeId !== null ? (int) $typeId : null,
                $payload,
            );
        } catch (Throwable $e) {
            Log::error('Échec création notification inbox KYC', [
                'user_id' => $user->id,
                'profile_id' => $profile->id,
                'type' => $typeCode,
                'error' => $e->getMessage(),
            ]);
        }

        try {
            $this->fcm->sendToUser($user, $title, $body, $payload);
        } catch (Throwable $e) {
            Log::error('Échec notification FCM KYC', [
                'user_id' => $user->id,
                'profile_id' => $profile->id,
                'type' => $typeCode,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
