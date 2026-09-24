<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class Device extends Model
{
    protected $fillable = [
    'user_id',
    'platform_id',
    'name',
    'type',
    'identifier',
    'os',
    'os_version',
    'model',
    'manufacturer',
    'actif',
    'last_used_at',
];
    public function sessionUser(): HasOne
    {
        return $this->hasOne(SessionUser::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function platform(): BelongsTo
    {
        return $this->belongsTo(Platform::class);
    }
}
