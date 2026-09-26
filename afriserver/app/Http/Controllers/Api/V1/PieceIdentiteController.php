<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Piece\StoreFichierPieceRequest;
use App\Http\Requests\Api\V1\Piece\StorePieceIdentiteRequest;
use App\Http\Requests\Api\V1\Piece\UpdatePieceIdentiteRequest;
use App\Http\Resources\FichierPieceResource;
use App\Http\Resources\PieceIdentiteResource;
use App\Http\Responses\ApiResponse;
use App\Models\TypePieceIdentite;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Contrats JSON pour les pièces d'identité utilisateur.
 * Persistance / conversion / validation → Node.js.
 */
class PieceIdentiteController extends Controller
{
    private const STATUT_LABELS = [
        'en_attente' => 'En attente de validation',
        'active' => 'Validée',
        'refusee' => 'Refusée',
    ];

    public function index(Request $request): JsonResponse
    {
        return ApiResponse::success('Liste des pièces d\'identité.', [
            'pieces' => [],
            'total' => 0,
            'meta' => [
                'pending_count' => 0,
                'active_count' => 0,
                'refused_count' => 0,
            ],
        ]);
    }

    public function show(Request $request, int|string $piece): JsonResponse
    {
        return ApiResponse::error(
            'Pièce introuvable. La récupération sera disponible après branchement Node.js.',
            ['piece_id' => [(string) $piece]],
            404
        );
    }

    public function store(StorePieceIdentiteRequest $request): JsonResponse
    {
        $data = $request->validated();
        $type = TypePieceIdentite::query()->find($data['type_piece_identite_id']);

        $piece = (object) [
            'id' => null,
            'type_piece_identite_id' => (int) $data['type_piece_identite_id'],
            'type' => $type,
            'numero' => $data['numero'],
            'date_delivrance' => $data['date_delivrance'] ?? null,
            'lieu_delivrance' => $data['lieu_delivrance'] ?? null,
            'statut_piece' => 'en_attente',
            'motif_refus' => null,
            'fichiers' => [],
            'created_at' => now()->toIso8601String(),
            'updated_at' => now()->toIso8601String(),
        ];

        return ApiResponse::success('Pièce soumise avec succès. En attente de traitement.', [
            'piece' => PieceIdentiteResource::make($piece),
            'next_step' => [
                'action' => 'upload_fichiers',
                'endpoint' => '/api/v1/pieces/{id}/fichiers',
                'message' => 'Ajoutez les scans / photos de la pièce.',
            ],
        ], 201);
    }

    public function update(UpdatePieceIdentiteRequest $request, int|string $piece): JsonResponse
    {
        $data = $request->validated();
        $typeId = $data['type_piece_identite_id'] ?? null;
        $type = $typeId ? TypePieceIdentite::query()->find($typeId) : null;
        $statut = $data['statut_piece'] ?? 'en_attente';

        $payload = (object) [
            'id' => (int) $piece,
            'type_piece_identite_id' => $typeId,
            'type' => $type,
            'numero' => $data['numero'] ?? null,
            'date_delivrance' => $data['date_delivrance'] ?? null,
            'lieu_delivrance' => $data['lieu_delivrance'] ?? null,
            'statut_piece' => $statut,
            'motif_refus' => $data['motif_refus'] ?? null,
            'fichiers' => [],
            'created_at' => null,
            'updated_at' => now()->toIso8601String(),
        ];

        return ApiResponse::success('Pièce mise à jour avec succès.', [
            'piece' => PieceIdentiteResource::make($payload),
        ]);
    }

    public function destroy(Request $request, int|string $piece): JsonResponse
    {
        return ApiResponse::success('Pièce supprimée avec succès.', [
            'deleted' => [
                'id' => (int) $piece,
                'deleted_at' => now()->toIso8601String(),
            ],
        ]);
    }

    public function storeFichiers(StoreFichierPieceRequest $request, int|string $piece): JsonResponse
    {
        $fichiers = [];

        foreach ($request->file('fichiers', []) as $file) {
            $fichiers[] = (object) [
                'id' => null,
                'nom_fichier' => $file->getClientOriginalName(),
                'chemin_fichier' => null,
                'type_fichier' => $file->getClientMimeType(),
                'taille_fichier' => $file->getSize(),
                'created_at' => now()->toIso8601String(),
            ];
        }

        return ApiResponse::success('Fichiers reçus avec succès. Conversion en attente.', [
            'piece_id' => (int) $piece,
            'fichiers' => FichierPieceResource::collection(collect($fichiers)),
            'total' => count($fichiers),
            'processing' => [
                'status' => 'queued',
                'message' => 'Les fichiers seront convertis et stockés par le service Node.js.',
            ],
        ], 201);
    }

    public function statut(Request $request, int|string $piece): JsonResponse
    {
        $code = 'en_attente';

        return ApiResponse::success('Statut de la pièce récupéré.', [
            'piece_id' => (int) $piece,
            'statut' => [
                'code' => $code,
                'label' => self::STATUT_LABELS[$code],
            ],
            'motif_refus' => null,
            'timeline' => [
                [
                    'step' => 'soumission',
                    'label' => 'Pièce soumise',
                    'done' => true,
                ],
                [
                    'step' => 'fichiers',
                    'label' => 'Fichiers reçus',
                    'done' => false,
                ],
                [
                    'step' => 'conversion',
                    'label' => 'Conversion des fichiers',
                    'done' => false,
                ],
                [
                    'step' => 'validation',
                    'label' => 'Validation administrative',
                    'done' => false,
                ],
            ],
        ]);
    }
}
