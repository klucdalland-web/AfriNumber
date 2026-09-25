<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FichierPieceResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $taille = $this->taille_fichier ?? null;

        return array_filter([
            'id' => $this->id ?? null,
            'nom_fichier' => $this->nom_fichier ?? null,
            'chemin_fichier' => $this->chemin_fichier ?? null,
            'type_fichier' => $this->type_fichier ?? null,
            'taille_fichier' => $taille,
            'taille_humaine' => is_int($taille) || is_numeric($taille)
                ? $this->formatBytes((int) $taille)
                : null,
            'created_at' => $this->normalizeDate($this->created_at ?? null),
        ], static fn ($value) => $value !== null && $value !== '');
    }

    private function formatBytes(int $bytes): string
    {
        if ($bytes < 1024) {
            return $bytes.' B';
        }

        if ($bytes < 1024 * 1024) {
            return round($bytes / 1024, 1).' KB';
        }

        return round($bytes / (1024 * 1024), 2).' MB';
    }

    private function normalizeDate(mixed $value): ?string
    {
        if ($value === null) {
            return null;
        }

        if (is_string($value)) {
            return $value;
        }

        return method_exists($value, 'toIso8601String')
            ? $value->toIso8601String()
            : (string) $value;
    }
}
