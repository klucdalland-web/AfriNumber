<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Platform extends Model
{
    /**
     * @var list<string>
     */
    protected $fillable = [
        'label',
        'description',
        'actif',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'actif' => 'boolean',
        ];
    }

    public function devices(): HasMany
    {
        return $this->hasMany(Device::class);
    }
}
