<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SmsMessage extends Model
{
    use HasUuids;

    protected $fillable = [
        'user_number_id',
        'sender',
        'content',
        'received_at',
        'is_read',
    ];

    protected $casts = [
        'received_at' => 'datetime',
        'is_read' => 'boolean',
    ];

    public function userNumber(): BelongsTo
    {
        return $this->belongsTo(UserNumber::class);
    }
}
