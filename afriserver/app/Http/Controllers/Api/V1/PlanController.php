<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PlanResource;
use App\Http\Responses\ApiResponse;
use App\Models\Plan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PlanController extends Controller
{
    /**
     * Catalogue des plans proposés (Free, Basic, Pro), avec currently sur le plan actif.
     */
    public function index(Request $request): JsonResponse
    {
        $currentPlanId = $request->user()->activeSubscription()?->plan_id;

        $plans = Plan::query()
            ->where('is_active', true)
            ->with('services')
            ->orderBy('sort_order')
            ->orderBy('id')
            ->get()
            ->each(function (Plan $plan) use ($currentPlanId): void {
                $plan->setAttribute('currently', $currentPlanId !== null && $plan->id === $currentPlanId);
            });

        return ApiResponse::success(
            $plans->isEmpty()
                ? 'Aucun plan disponible.'
                : 'Plans récupérés avec succès.',
            [
                'plans' => PlanResource::collection($plans),
                'total' => $plans->count(),
            ]
        );
    }
}
