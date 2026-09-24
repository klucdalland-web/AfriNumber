<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;

class SessionUser extends Model
{
    /**
     * @var list<string>
     */
    protected $fillable = [
        'device_id',
        'user_id',
        'user_agent',
        'ip_address',
        'country',
        'city',
        'region',
        'timezone',
        'latitude',
        'internet_provider',
        'network_type',
        'is_active',
    ];

    protected $primaryKey = 'device_id';

    public $incrementing = false;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'latitude' => 'decimal:8',
        ];
    }

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function deviceTokenFcm(): HasOne
    {
        return $this->hasOne(DeviceTokenFcm::class, 'device_id');
    }
}
