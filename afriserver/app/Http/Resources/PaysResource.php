<?php

namespace App\Http\Resources;

use App\Models\Pays;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Pays
 */
class PaysResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'label' => $this->label,
            'code' => $this->code,
            'indicatif' => $this->indicatif,
            'actif' => $this->when(isset($this->actif), (bool) $this->actif),
            'organisation_id' => $this->organisation_id,
            'organisation' => $this->whenLoaded('organisation', function () {
                return [
                    'id' => $this->organisation?->id,
                    'label' => $this->organisation?->label,
                    'description' => $this->organisation?->description,
                ];
            }),
        ];
    }
}
