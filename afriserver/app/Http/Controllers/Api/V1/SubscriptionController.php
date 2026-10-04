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
