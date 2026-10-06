<?php

namespace App\Services;

use App\Models\Profile;
use App\Models\TypeNotification;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use InvalidArgumentException;
use Throwable;

/**
 * Actions KYC déclenchées depuis le dashboard Filament.
 *
 * Seuls les dossiers en validation manuelle (verdict n8n `manual_review`)
 * peuvent être approuvés ou rejetés par un opérateur.
 */
class KycAdminService
{
    public function __construct(
        private readonly FcmNotificationService $fcm,
    ) {}

    public function approve(User $user, ?string $title = null, ?string $message = null): Profile
    {
        return DB::transaction(function () use ($user, $title, $message): Profile {
            $profile = $this->profileFor($user);
            $this->assertManualReview($profile);

            $profile->update([
                'status' => Profile::STATUS_APPROUVE,
                'rejection_reason' => null,
            ]);

            $user->update(['status_valide' => 'valide']);

            $profile->clearStoredDocuments();

            $this->notify(
                $user,
                $profile,
                TypeNotification::CODE_KYC_APPROVED,
                $title ?: 'Identité vérifiée',
                $message ?: 'Votre vérification d\'identité a été approuvée.',
                'approved',
            );

            return $profile->fresh();
        });
    }

    public function reject(User $user, ?string $reason = null, ?string $title = null, ?string $message = null): Profile
    {
        return DB::transaction(function () use ($user, $reason, $title, $message): Profile {
            $profile = $this->profileFor($user);
            $this->assertManualReview($profile);

            $profile->update([
                'status' => Profile::STATUS_REJETE,
                'rejection_reason' => $reason,
            ]);

            $user->update(['status_valide' => 'non_valide']);

            $profile->clearStoredDocuments();

            $body = $message
                ?: ($reason ?: 'Votre vérification d\'identité a été refusée.');

            $this->notify(
                $user,
                $profile,
                TypeNotification::CODE_KYC_REJECTED,
                $title ?: 'Vérification refusée',
                $body,
                'rejected',
                $reason,
            );

            return $profile->fresh();
        });
    }

    private function profileFor(User $user): Profile
    {
        $profile = $user->profile ?? Profile::query()->where('user_id', $user->id)->first();

        if (! $profile instanceof Profile) {
            throw new InvalidArgumentException('Aucun dossier KYC pour ce client.');
        }

        return $profile;
    }

    private function assertManualReview(Profile $profile): void
    {
        if (! $profile->isAwaitingManualReview()) {
            throw new InvalidArgumentException(
                'Seuls les profils en validation manuelle peuvent être approuvés ou rejetés.'
            );
        }
    }

    private function notify(
        User $user,
        Profile $profile,
        string $type,
        string $title,
        string $body,
        string $kycStatus,
        ?string $reason = null,
    ): void {
        try {
            $this->fcm->sendToUser($user, $title, $body, [
                'type' => $type,
                'profile_id' => $profile->id,
                'kyc_status' => $kycStatus,
                'reason' => $reason,
            ]);
        } catch (Throwable $e) {
            Log::error('Échec notification FCM (admin KYC)', [
                'user_id' => $user->id,
                'profile_id' => $profile->id,
                'kyc_status' => $kycStatus,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
