<?php

namespace App\Services;

use App\Models\Compte;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use InvalidArgumentException;
use RuntimeException;

class CompteService
{
    /**
     * Retourne le compte de l'utilisateur, en le créant s'il n'existe pas.
     */
    public function ensureCompte(User $user): Compte
    {
        $compte = Compte::query()->where('user_id', $user->id)->first();

        if ($compte !== null) {
            $user->setRelation('compte', $compte);

            return $compte;
        }

        $compte = Compte::query()->create([
            'user_id' => $user->id,
            'numero_compte' => $this->generateNumeroCompte($user),
            'solde' => 0,
            'statut' => Compte::STATUT_ACTIF,
        ]);

        $user->setRelation('compte', $compte);

        return $compte;
    }

    public function solde(User $user): float
    {
        return (float) $this->ensureCompte($user)->solde;
    }

    /**
     * Crédite le compte (montant en USD / unité wallet).
     */
    public function credit(User $user, float $amount): Compte
    {
        if ($amount < 0) {
            throw new InvalidArgumentException('Le montant à créditer doit être positif ou nul.');
        }

        return DB::transaction(function () use ($user, $amount): Compte {
            $this->ensureCompte($user);

            $compte = Compte::query()
                ->where('user_id', $user->id)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $compte->isActif()) {
                throw new RuntimeException('Le compte n\'est pas actif.');
            }

            $compte->increment('solde', $amount);
            $compte = $compte->fresh();
            $user->setRelation('compte', $compte);

            return $compte;
        });
    }

    /**
     * Débite le compte. Lève une exception si solde insuffisant.
     */
    public function debit(User $user, float $amount): Compte
    {
        if ($amount <= 0) {
            throw new InvalidArgumentException('Le montant à débiter doit être strictement positif.');
        }

        return DB::transaction(function () use ($user, $amount): Compte {
            $this->ensureCompte($user);

            $compte = Compte::query()
                ->where('user_id', $user->id)
                ->lockForUpdate()
                ->firstOrFail();

            if (! $compte->isActif()) {
                throw new RuntimeException('Le compte n\'est pas actif.');
            }

            if ((float) $compte->solde < $amount) {
                throw new RuntimeException('Solde insuffisant.');
            }

            $compte->decrement('solde', $amount);
            $compte = $compte->fresh();
            $user->setRelation('compte', $compte);

            return $compte;
        });
    }

    public function generateNumeroCompte(User $user): string
    {
        do {
            $numero = sprintf('AFN%06d%s', $user->id, strtoupper(bin2hex(random_bytes(4))));
        } while (Compte::query()->where('numero_compte', $numero)->exists());

        return $numero;
    }
}
