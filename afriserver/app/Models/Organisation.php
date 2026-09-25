<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasManyThrough;

class Organisation extends Model
{
    protected $fillable = [
        'label',
        'description',
        'actif',
    ];

    public function pays(): HasMany
    {
        return $this->hasMany(Pays::class);
    }

    public function users(): HasManyThrough
    {
        return $this->hasManyThrough(User::class, Pays::class);
    }
}
