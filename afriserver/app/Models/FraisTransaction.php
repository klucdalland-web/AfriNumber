<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FraisTransaction extends Model
{
    protected $table = 'frais_transaction';

    protected $fillable = [
        'type_transaction_id', 'pays_id', 'montant_fixe',
        'taux_pourcentage', 'montant_min', 'montant_max', 'statut',
    ];

    protected $casts = [
        'montant_fixe' => 'decimal:8',
        'taux_pourcentage' => 'decimal:4',
        'montant_min' => 'decimal:8',
        'montant_max' => 'decimal:8',
    ];

    public function typeTransaction() { return $this->belongsTo(TypeTransaction::class); }
    public function pays()            { return $this->belongsTo(Pays::class); }

    // Calcul du frais pour un montant donné
    public function calculer(string $montant): string
    {
        $frais = bcadd($this->montant_fixe, bcmul($montant, bcdiv($this->taux_pourcentage, '100', 8), 8), 8);

        if ($this->montant_min !== null && bccomp($frais, $this->montant_min, 8) < 0) {
            $frais = $this->montant_min;
        }
        if ($this->montant_max !== null && bccomp($frais, $this->montant_max, 8) > 0) {
            $frais = $this->montant_max;
        }

        return $frais;
    }
}