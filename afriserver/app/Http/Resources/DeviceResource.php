<?php

namespace App\Http\Resources;

use App\Models\Device;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Device
 */
class DeviceResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $currentIdentifier = $request->header('X-Device-Id');

        return [
            'id' => $this->id,
            'name' => $this->name,
            'model' => $this->model,
            'os_version' => $this->os_version,
            'platform' => $this->whenLoaded('platform', fn () => $this->platform?->label),
            'actif' => (bool) $this->actif,
            'is_current' => $currentIdentifier !== null
                && $this->identifier !== null
                && hash_equals((string) $this->identifier, (string) $currentIdentifier),
            'last_used_at' => $this->last_used_at?->toIso8601String(),
            'session' => $this->whenLoaded('sessionUser', function () {
                if (! $this->sessionUser) {
                    return null;
                }

                return [
                    'is_active' => (bool) $this->sessionUser->is_active,
                    'ip_address' => $this->sessionUser->ip_address,
                    'country' => $this->sessionUser->country,
                    'city' => $this->sessionUser->city,
                    'region' => $this->sessionUser->region,
                    'timezone' => $this->sessionUser->timezone,
                    'internet_provider' => $this->sessionUser->internet_provider,
                    'last_activity_at' => $this->sessionUser->updated_at?->toIso8601String(),
                ];
            }),
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
