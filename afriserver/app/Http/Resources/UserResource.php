<?php

namespace App\Http\Resources;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 */
class UserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'name' => $this->name,
            'email' => $this->email,
            'phone_number' => $this->phone_number,
            'statut' => $this->statut,
            'status_valide' => $this->status_valide,
            'type_user' => TypeUserResource::make($this->whenLoaded('typeUser')),
            'pays' => PaysResource::make($this->whenLoaded('pays')),
            'organisation' => $this->when(
                $this->relationLoaded('pays') && $this->pays?->relationLoaded('organisation'),
                fn () => OrganisationResource::make($this->pays?->organisation)
            ),
        ];
    }
}
