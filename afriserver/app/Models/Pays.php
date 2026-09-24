<?php

namespace App\Models;

use Database\Factories\PaysFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Pays extends Model
{
    /** @use HasFactory<PaysFactory> */
    use HasFactory;

    /**
     * @var list<string>
     */
    protected $fillable = [
        'continent_id',
        'organisation_id',
        'label',
        'code',
        'indicatif',
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

    public function continent(): BelongsTo
    {
        return $this->belongsTo(Continent::class);
    }

    public function organisation(): BelongsTo
    {
        return $this->belongsTo(Organisation::class);
    }
}
