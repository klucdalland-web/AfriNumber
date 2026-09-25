<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ObservabilityLog extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'user_id',
        'device_id',
        'device_identifier',
        'category',
        'action',
        'level',
        'message',
        'method',
        'path',
        'route_name',
        'status_code',
        'ip_address',
        'user_agent',
        'request_payload',
        'context',
        'data_before',
        'data_after',
        'session',
        'location',
        'duration_ms',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'request_payload' => 'array',
            'context' => 'array',
            'data_before' => 'array',
            'data_after' => 'array',
            'session' => 'array',
            'location' => 'array',
            'created_at' => 'datetime',
            'status_code' => 'integer',
            'duration_ms' => 'integer',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function device(): BelongsTo
    {
        return $this->belongsTo(Device::class);
    }
}
