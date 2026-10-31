<?php

namespace App\Models;

use Database\Factories\PaysFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

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
        'devise_id',
        'label',
        'code',
        'currency_code',
        'currency_symbol',
        'exchange_rate',
        'indicatif',
        'timezone',
        'description',
        'actif',
    ];

    protected function casts(): array
    {
        return [
            'actif' => 'boolean',
            'exchange_rate' => 'decimal:4',
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

    public function devise(): BelongsTo
    {
        return $this->belongsTo(Devise::class);
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class);
    }

    /**
     * @return HasMany<FraisTransaction, $this>
     */
    public function fraisTransactions(): HasMany
    {
        return $this->hasMany(FraisTransaction::class);
    }
}
