<?php

namespace App\Models;

use Database\Factories\CompteFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Compte extends Model
{
    /** @use HasFactory<CompteFactory> */
    use HasFactory;

    public const STATUT_ACTIF = 'ACTIF';

    public const STATUT_SUSPENDU = 'SUSPENDU';

    public const STATUT_FERME = 'FERME';

    /**
     * @var list<string>
     */
    protected $fillable = [
        'numero_compte',
        'solde',
        'statut',
        'user_id',
    ];

    /**
     * @var array<string, mixed>
     */
    protected $attributes = [
        'solde' => 0,
        'statut' => self::STATUT_ACTIF,
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'solde' => 'decimal:8',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isActif(): bool
    {
        return $this->statut === self::STATUT_ACTIF;
    }
}
