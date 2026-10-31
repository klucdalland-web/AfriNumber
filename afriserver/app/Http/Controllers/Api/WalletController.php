<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\TypeTransaction;
use App\Services\CompteService;
use App\Services\CurrencyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function __construct(
        protected CurrencyService $currencyService,
        protected CompteService $compteService,
    ) {}

    /**
     * Simule un rechargement de solde (pour tests).
     * En production, ceci serait remplacé par un webhook de Paystack/Stripe.
     */
    public function topUp(Request $request)
    {
        $request->validate([
            'amount' => 'required|numeric|min:1',
        ]);

        $user = Auth::user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non authentifié.'], 401);
        }

        $localAmount = (float) $request->amount;
        $pays = $user->pays;

        if (! $pays) {
            return response()->json(['success' => false, 'message' => 'Pays de l\'utilisateur non configuré.'], 422);
        }

        // Convertit le montant local en USD avant crédit sur le compte
        $usdAmount = $this->currencyService->convertLocalToUsd($localAmount, $pays);

        DB::transaction(function () use ($user, $localAmount, $usdAmount) {
            $this->compteService->credit($user, $usdAmount);

            $typeTransaction = TypeTransaction::where('code', 'topup')->first();

            $user->transactions()->create([
                'type_transaction_id' => $typeTransaction ? $typeTransaction->id : null,
                'amount' => $usdAmount,
                'currency' => $user->pays->currency_code ?? 'USD',
                'payment_method' => 'wallet_topup',
                'status' => 'paid',
                'paid_at' => now(),
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Solde rechargé avec succès !',
            'amount_paid_local' => $localAmount,
            'amount_credited_usd' => $usdAmount,
            'new_balance_usd' => $this->compteService->solde($user->fresh()),
            'numero_compte' => $this->compteService->ensureCompte($user)->numero_compte,
        ]);
    }

    public function balance()
    {
        $user = Auth::user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non authentifié.'], 401);
        }

        $pays = $user->pays;
        $compte = $this->compteService->ensureCompte($user);
        $balanceUsd = (float) $compte->solde;
        $balanceLocal = $pays
            ? $this->currencyService->convertUsdToLocal($balanceUsd, $pays)
            : $balanceUsd;

        return response()->json([
            'success' => true,
            'balance_usd' => $balanceUsd,
            'balance_local' => $balanceLocal,
            'currency' => $pays->currency_code ?? 'USD',
            'numero_compte' => $compte->numero_compte,
            'statut_compte' => $compte->statut,
        ]);
    }
}
