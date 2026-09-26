<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PieceIdentiteResource extends JsonResource
{
    private const STATUT_LABELS = [
        'en_attente' => 'En attente de validation',
        'active' => 'Validée',
        'refusee' => 'Refusée',
    ];

    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $statut = $this->statut_piece ?? 'en_attente';
        $type = $this->type ?? $this->type_piece_identite ?? null;
        $fichiers = collect($this->fichiers ?? []);

        $payload = [
            'id' => $this->id ?? null,
            'type_piece_identite_id' => $this->type_piece_identite_id ?? null,
            'type' => $type ? TypePieceIdentiteResource::make($type)->resolve() : null,
            'numero' => $this->numero ?? null,
            'date_delivrance' => $this->date_delivrance ?? null,
            'lieu_delivrance' => $this->lieu_delivrance ?? null,
            'statut' => [
                'code' => $statut,
                'label' => self::STATUT_LABELS[$statut] ?? $statut,
            ],
            'fichiers' => FichierPieceResource::collection($fichiers)->resolve(),
            'fichiers_count' => $fichiers->count(),
            'created_at' => $this->created_at ?? null,
            'updated_at' => $this->updated_at ?? null,
        ];

        if ($statut === 'refusee') {
            $payload['motif_refus'] = $this->motif_refus ?? null;
        }

        return array_filter(
            $payload,
            static fn ($value) => $value !== null && $value !== ''
        );
    }
}
