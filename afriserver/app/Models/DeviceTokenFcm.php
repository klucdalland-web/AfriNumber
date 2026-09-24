<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class DeviceTokenFcm extends Model
{
    /**
     * @var list<string>
     */
    protected $fillable = [
        'device_id',
        'token',
        'actif',
    ];

    protected $primaryKey = 'device_id';

    public $incrementing = false;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'actif' => 'boolean',
        ];
    }

    public function sessionUser(): BelongsTo
    {
        return $this->belongsTo(SessionUser::class, 'device_id');
    }
}
