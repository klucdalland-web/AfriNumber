<?php

namespace App\Services;

use App\Models\Plan;
use App\Models\Subscription;
use App\Models\User;
use RuntimeException;

class SubscriptionService
{
    /**
     * Attribue le plan Free (essai) à un nouvel utilisateur.
     *
     * Idempotent : si un abonnement actif existe déjà, il est renvoyé tel quel.
     */
    public function assignFreePlan(User $user): Subscription
    {
        
        $existing = $user->activeSubscription();

        if ($existing !== null) {
            return $existing;
        }

        $plan = Plan::query()
            ->where('code', Plan::CODE_FREE)
            ->where('is_active', true)
            ->first();

        if ($plan === null) {
            throw new RuntimeException('Le plan Free est introuvable ou inactif.');
        }

        $startsAt = now();

        return $user->subscriptions()->create([
            'plan_id' => $plan->id,
            'status' => Subscription::STATUS_ACTIVE,
            'starts_at' => $startsAt,
            'ends_at' => $startsAt->copy()->addDays((int) $plan->duration_days),
            'auto_renew' => false,
        ]);
    }
}
