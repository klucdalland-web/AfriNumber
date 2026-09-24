<?php

namespace App\Http\Resources;

use App\Models\Organisation;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Organisation
 */
class OrganisationResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'label' => $this->label,
            'description' => $this->description,
            
        ];
    }
}
