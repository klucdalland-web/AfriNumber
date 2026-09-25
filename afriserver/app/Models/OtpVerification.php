<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OtpVerification extends Model
{
    protected $fillable = [
        'email',
        'phone_number',
        'purpose',
        'code',
        'payload',
        'attempts',
        'locked_until',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'payload' => 'array',
            'locked_until' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }
}