<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaysResource;
use App\Http\Responses\ApiResponse;
use App\Models\Pays;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Pays rattachés à une organisation (organisation_id non null).
 */
class PaysController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $pays = Pays::query()
            ->whereNotNull('organisation_id')
            ->where('actif', true)
            ->with('organisation:id,label,description')
            ->orderBy('label')
            ->get();

        return ApiResponse::success(
            $pays->isEmpty()
                ? 'Aucun pays rattaché à une organisation.'
                : 'Pays récupérés avec succès.',
            [
                'pays' => PaysResource::collection($pays),
                'total' => $pays->count(),
            ]
        );
    }

    public function show(Request $request, int|string $pay): JsonResponse
    {
        $pays = Pays::query()
            ->whereNotNull('organisation_id')
            ->where('actif', true)
            ->with('organisation:id,label,description')
            ->find($pay);

        if (! $pays) {
            return ApiResponse::error('Pays introuvable.', null, 404);
        }

        return ApiResponse::success('Pays récupéré avec succès.', [
            'pays' => PaysResource::make($pays),
        ]);
    }
}
