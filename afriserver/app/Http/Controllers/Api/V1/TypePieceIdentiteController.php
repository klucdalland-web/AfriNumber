<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\TypePieceIdentiteResource;
use App\Http\Responses\ApiResponse;
use App\Models\TypePieceIdentite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Types de pièces d'identité (référentiel).
 */
class TypePieceIdentiteController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $types = TypePieceIdentite::query()
            ->orderBy('label')
            ->get();

        return ApiResponse::success(
            $types->isEmpty()
                ? 'Aucun type de pièce disponible.'
                : 'Types de pièces récupérés avec succès.',
            [
                'types' => TypePieceIdentiteResource::collection($types),
                'total' => $types->count(),
            ]
        );
    }

    public function show(Request $request, int|string $typePieceIdentite): JsonResponse
    {
        $type = TypePieceIdentite::query()->find($typePieceIdentite);

        if (! $type) {
            return ApiResponse::error('Type de pièce introuvable.', null, 404);
        }

        return ApiResponse::success('Type de pièce récupéré avec succès.', [
            'type' => TypePieceIdentiteResource::make($type),
        ]);
    }
}
