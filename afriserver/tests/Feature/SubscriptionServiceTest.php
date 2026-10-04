<?php

use App\Models\Plan;
use App\Models\Subscription;
use App\Models\User;
use App\Services\SubscriptionService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use RuntimeException;

uses(RefreshDatabase::class);

function createFreePlan(int $durationDays = 14): Plan
{
    return Plan::query()->create([
        'code' => Plan::CODE_FREE,
        'label' => 'Free',
        'description' => 'Essai',
        'price' => 0,
        'currency' => 'XOF',
        'duration_days' => $durationDays,
        'max_numbers' => 1,
        'is_active' => true,
        'sort_order' => 0,
    ]);
}

test('assignFreePlan creates an active free subscription for the user', function (): void {
    $plan = createFreePlan(14);
    $user = User::factory()->create();

    $subscription = app(SubscriptionService::class)->assignFreePlan($user);

    expect($subscription)
        ->toBeInstanceOf(Subscription::class)
        ->and($subscription->user_id)->toBe($user->id)
        ->and($subscription->plan_id)->toBe($plan->id)
        ->and($subscription->status)->toBe(Subscription::STATUS_ACTIVE)
        ->and($subscription->auto_renew)->toBeFalse()
        ->and($subscription->starts_at)->not->toBeNull()
        ->and($subscription->ends_at?->equalTo(
            $subscription->starts_at->copy()->addDays(14)
        ))->toBeTrue();

    expect($user->fresh()->activeSubscription()?->plan?->code)->toBe(Plan::CODE_FREE);
});

test('assignFreePlan is idempotent when an active subscription already exists', function (): void {
    createFreePlan();
    $user = User::factory()->create();
    $service = app(SubscriptionService::class);

    $first = $service->assignFreePlan($user);
    $second = $service->assignFreePlan($user->fresh());

    expect($second->id)->toBe($first->id)
        ->and(Subscription::query()->where('user_id', $user->id)->count())->toBe(1);
});

test('assignFreePlan fails when the free plan is missing', function (): void {
    $user = User::factory()->create();

    app(SubscriptionService::class)->assignFreePlan($user);
})->throws(RuntimeException::class, 'Le plan Free est introuvable ou inactif.');
