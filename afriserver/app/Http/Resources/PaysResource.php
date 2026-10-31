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
            'timezone' => $this->timezone,
            'currency_code' => $this->currency_code,
            'currency_symbol' => $this->currency_symbol,
            'exchange_rate' => $this->exchange_rate,
            'devise_id' => $this->devise_id,
            'actif' => $this->when(isset($this->actif), (bool) $this->actif),
            'organisation_id' => $this->organisation_id,
            'devise' => $this->whenLoaded('devise', function () {
                return [
                    'id' => $this->devise?->id,
                    'code' => $this->devise?->code,
                    'label' => $this->devise?->label,
                    'symbole' => $this->devise?->symbole,
                ];
            }),
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
