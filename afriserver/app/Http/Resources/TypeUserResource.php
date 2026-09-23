<?php

namespace App\Http\Resources;

use App\Models\TypeUser;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin TypeUser
 */
class TypeUserResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'label' => $this->label,
            'code' => $this->code,
            'description' => $this->description,
        ];
    }
}
