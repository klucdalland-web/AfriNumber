<?php

namespace App\Http\Resources;

use App\Models\Plan;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Plan
 */
class PlanResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'label' => $this->label,
            'description' => $this->description,
            'price' => $this->price,
            'currency' => $this->currency,
            'duration_days' => $this->duration_days,
            'max_numbers' => $this->max_numbers,
            'currently' => $this->when(
                array_key_exists('currently', $this->resource->getAttributes()),
                fn (): bool => (bool) $this->currently,
            ),
            'services' => $this->whenLoaded('services', function () {
                return $this->services->map(fn ($service): array => [
                    'code' => $service->code,
                    'label' => $service->label,
                    'quota' => $service->pivot->quota,
                ])->values()->all();
            }),
        ];
    }
}
