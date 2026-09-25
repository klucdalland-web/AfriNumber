<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TypePieceIdentite extends Model
{
    protected $fillable = [
        'label',
        'description',
    ];

    public function pieceIdentites(): HasMany
    {
        return $this->hasMany(PieceIdentite::class);
    }
}
