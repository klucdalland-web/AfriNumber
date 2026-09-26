<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\OrganisationResource;
use App\Http\Resources\PaysResource;
use App\Http\Responses\ApiResponse;
use App\Models\Organisation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Organisations et pays rattachés.
 */
class OrganisationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $organisations = Organisation::query()
            ->where('actif', true)
            ->withCount(['pays' => fn ($q) => $q->where('actif', true)])
            ->orderBy('label')
            ->get();

        return ApiResponse::success(
            $organisations->isEmpty()
                ? 'Aucune organisation disponible.'
                : 'Organisations récupérées avec succès.',
            [
                'organisations' => OrganisationResource::collection($organisations),
                'total' => $organisations->count(),
            ]
        );
    }

    public function show(Request $request, int|string $organisation): JsonResponse
    {
        $org = Organisation::query()
            ->where('actif', true)
            ->withCount(['pays' => fn ($q) => $q->where('actif', true)])
            ->find($organisation);

        if (! $org) {
            return ApiResponse::error('Organisation introuvable.', null, 404);
        }

        return ApiResponse::success('Organisation récupérée avec succès.', [
            'organisation' => OrganisationResource::make($org),
        ]);
    }

    /**
     * Pays (contrées) liés à une organisation.
     */
    public function pays(Request $request, int|string $organisation): JsonResponse
    {
        $org = Organisation::query()
            ->where('actif', true)
            ->find($organisation);

        if (! $org) {
            return ApiResponse::error('Organisation introuvable.', null, 404);
        }

        $pays = $org->pays()
            ->where('actif', true)
            ->orderBy('label')
            ->get();

        return ApiResponse::success(
            $pays->isEmpty()
                ? 'Aucun pays rattaché à cette organisation.'
                : 'Pays de l\'organisation récupérés avec succès.',
            [
                'organisation' => [
                    'id' => $org->id,
                    'label' => $org->label,
                ],
                'pays' => PaysResource::collection($pays),
                'total' => $pays->count(),
            ]
        );
    }
}
