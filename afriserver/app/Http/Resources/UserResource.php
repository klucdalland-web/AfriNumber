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
            // 'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'phone_number' => $this->phone_number,
            'statut' => $this->statut,
            'status_valide' => $this->status_valide,
            // 'organisation_id' => $this->organisation_id,
            // 'type_user_id' => $this->type_user_id,
            // 'email_verified_at' => $this->email_verified_at,
            // 'created_at' => $this->created_at,
            // 'updated_at' => $this->updated_at,
            'type_user' => TypeUserResource::make($this->whenLoaded('typeUser')),
            'organisation' => OrganisationResource::make($this->whenLoaded('organisation')),
        ];
    }
}
