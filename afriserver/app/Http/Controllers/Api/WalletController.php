<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
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

        $amount = (float) $request->amount;

        DB::transaction(function () use ($user, $amount) {
            $user->increment('balance', $amount);

            // Optionnel : Créer une transaction d'historique
            $user->transactions()->create([
                'amount' => $amount,
                'type' => 'deposit', // Assuming this type exists in TypeTransaction
                'description' => 'Rechargement de solde via API',
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Solde rechargé avec succès !',
            'new_balance' => $user->fresh()->balance,
        ]);
    }

    public function balance()
    {
        $user = Auth::user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non authentifié.'], 401);
        }

        $pays = $user->pays;
        $balanceUsd = (float) $user->balance;
        $balanceLocal = $this->currencyService->convertUsdToLocal($balanceUsd, $pays);

        return response()->json([
            'success' => true,
            'balance_usd' => $balanceUsd,
            'balance_local' => $balanceLocal,
            'currency' => $pays->currency_code ?? 'USD',
        ]);
    }
}
