<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Organisation extends Model
{
    public function pays(): HasMany
    {
        return $this->hasMany(Pays::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }
}
