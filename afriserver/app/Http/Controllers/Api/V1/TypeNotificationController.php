<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\TypeNotificationResource;
use App\Http\Responses\ApiResponse;
use App\Models\TypeNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Types de notifications (référentiel).
 */
class TypeNotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $types = TypeNotification::query()
            ->where('actif', true)
            ->orderBy('sort_order')
            ->orderBy('label')
            ->get();

        return ApiResponse::success(
            $types->isEmpty()
                ? 'Aucun type de notification disponible.'
                : 'Types de notifications récupérés avec succès.',
            [
                'types' => TypeNotificationResource::collection($types),
                'total' => $types->count(),
            ]
        );
    }

    public function show(Request $request, int|string $typeNotification): JsonResponse
    {
        $type = TypeNotification::query()
            ->where('actif', true)
            ->find($typeNotification);

        if (! $type) {
            return ApiResponse::error('Type de notification introuvable.', null, 404);
        }

        return ApiResponse::success('Type de notification récupéré avec succès.', [
            'type' => TypeNotificationResource::make($type),
        ]);
    }
}
