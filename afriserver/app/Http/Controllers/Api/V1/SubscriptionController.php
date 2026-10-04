<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\SubscriptionResource;
use App\Http\Responses\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SubscriptionController extends Controller
{
    /**
     * Tous les abonnements de l'utilisateur (plan + services), avec is_currently_active.
     */
    public function index(Request $request): JsonResponse
    {
        $abonnements = $request->user()
            ->subscriptions()
            ->with(['plan.services'])
            ->orderByDesc('starts_at')
            ->orderByDesc('id')
            ->get();

        return ApiResponse::success(null, [
            'abonnements' => SubscriptionResource::collection($abonnements),
        ]);
    }

    /**
     * Abonnement actif de l'utilisateur authentifié (plan + services inclus).
     */
    public function show(Request $request): JsonResponse
    {
        $subscription = $request->user()->activeSubscription();

        return ApiResponse::success(null, [
            'abonnement' => $subscription !== null
                ? SubscriptionResource::make($subscription)
                : null,
        ]);
    }
}
