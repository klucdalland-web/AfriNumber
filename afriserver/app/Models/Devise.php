<?php

namespace App\Models;

use Database\Factories\DeviseFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Devise extends Model
{
    /** @use HasFactory<DeviseFactory> */
    use HasFactory;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'code',
        'label',
        'symbole',
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

    /**
     * @return HasMany<Pays, $this>
     */
    public function pays(): HasMany
    {
        return $this->hasMany(Pays::class);
    }
}
