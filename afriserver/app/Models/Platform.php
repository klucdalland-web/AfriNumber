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

    /**
     * Résout une plateforme à partir de la clé API (ex. "ios", "android", "web").
     */
    public static function findByKey(string $key): ?self
    {
        $normalized = strtolower(trim($key));

        if ($normalized === '') {
            return null;
        }

        return static::query()
            ->whereRaw('LOWER(label) = ?', [$normalized])
            ->first();
    }

    public function devices(): HasMany
    {
        return $this->hasMany(Device::class);
    }
}
