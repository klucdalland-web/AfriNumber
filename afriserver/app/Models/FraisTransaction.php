<?php

namespace App\Models;

use Database\Factories\FraisTransactionFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class FraisTransaction extends Model
{
    /** @use HasFactory<FraisTransactionFactory> */
    use HasFactory;

    public const STATUT_ACTIF = 'ACTIF';

    public const STATUT_INACTIF = 'INACTIF';

    /**
     * @var list<string>
     */
    protected $fillable = [
        'type_transaction_id',
        'pays_id',
        'montant_fixe',
        'taux_pourcentage',
        'montant_min',
        'montant_max',
        'statut',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'montant_fixe' => 'decimal:8',
            'taux_pourcentage' => 'decimal:4',
            'montant_min' => 'decimal:8',
            'montant_max' => 'decimal:8',
        ];
    }

    /**
     * @return BelongsTo<TypeTransaction, $this>
     */
    public function typeTransaction(): BelongsTo
    {
        return $this->belongsTo(TypeTransaction::class);
    }

    /**
     * @return BelongsTo<Pays, $this>
     */
    public function pays(): BelongsTo
    {
        return $this->belongsTo(Pays::class);
    }

    /**
     * Calcule les frais pour un montant (USD), échelle 8, bcmath uniquement.
     */
    public function calculer(string $montant): string
    {
        $taux = (string) $this->taux_pourcentage;
        $fixe = (string) $this->montant_fixe;

        $frais = bcadd(
            $fixe,
            bcmul($montant, bcdiv($taux, '100', 8), 8),
            8,
        );

        if ($this->montant_min !== null && bccomp($frais, (string) $this->montant_min, 8) < 0) {
            $frais = (string) $this->montant_min;
        }

        if ($this->montant_max !== null && bccomp($frais, (string) $this->montant_max, 8) > 0) {
            $frais = (string) $this->montant_max;
        }

        return $frais;
    }

    /**
     * Règle ACTIVE du pays si elle existe, sinon règle par défaut (pays_id null), sinon null.
     */
    public static function pourOperation(int $typeTransactionId, ?int $paysId): ?self
    {
        if ($paysId !== null) {
            $paysRule = static::query()
                ->where('type_transaction_id', $typeTransactionId)
                ->where('pays_id', $paysId)
                ->where('statut', self::STATUT_ACTIF)
                ->first();

            if ($paysRule !== null) {
                return $paysRule;
            }
        }

        return static::query()
            ->where('type_transaction_id', $typeTransactionId)
            ->whereNull('pays_id')
            ->where('statut', self::STATUT_ACTIF)
            ->first();
    }
}
