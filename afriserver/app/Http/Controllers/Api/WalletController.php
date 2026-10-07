<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CurrencyService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class WalletController extends Controller
{
    public function __construct(
        protected CurrencyService $currencyService
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

        // Convert the local amount to USD before storing it in the balance
        $usdAmount = $this->currencyService->convertLocalToUsd($localAmount, $pays);

        DB::transaction(function () use ($user, $localAmount, $usdAmount) {
            $user->increment('balance', $usdAmount);

            // Récupération dynamique du type de transaction pour le rechargement
            $typeTransaction = \App\Models\TypeTransaction::where('code', 'topup')->first();

            // On enregistre la transaction avec le payment_method obligatoire
            $user->transactions()->create([
                'type_transaction_id' => $typeTransaction ? $typeTransaction->id : null,
                'amount' => $usdAmount,
                'currency' => $user->pays->currency_code ?? 'USD',
                'payment_method' => 'wallet_topup',
                'status' => 'paid',
                'description' => "Rechargement de {$localAmount} " . ($user->pays->currency_code ?? 'XOF'),
                'paid_at' => now(),
            ]);
        });

        return response()->json([
            'success' => true,
            'message' => 'Solde rechargé avec succès !',
            'amount_paid_local' => $localAmount,
            'amount_credited_usd' => $usdAmount,
            'new_balance_usd' => $user->fresh()->balance,
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
