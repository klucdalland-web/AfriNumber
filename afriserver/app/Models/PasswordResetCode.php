<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PasswordResetCode extends Model
{
    protected $fillable = [
        'email',
        'phone_number',
        'code',
        'attempts',
        'resend_count',
        'locked_until',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'locked_until' => 'datetime',
            'expires_at' => 'datetime',
        ];
    }
}
