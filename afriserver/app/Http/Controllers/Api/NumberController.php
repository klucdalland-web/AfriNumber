<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\NumberProviderManager;
use App\Models\UserNumber;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Auth;

class NumberController extends Controller
{
    protected NumberProviderManager $providerManager;

    public function __construct(NumberProviderManager $providerManager, protected \App\Services\CurrencyService $currencyService)
    {
        $this->providerManager = $providerManager;
    }

    // 1. Rechercher des numéros
    public function search(Request $request)
    {
        $user = Auth::user();
        $country = strtoupper($request->input('country', 'US'));
        $service = $request->input('service', 'whatsapp');

        $provider = $this->providerManager->getProvider();
        $numbers = $provider->searchNumbers($country, $service);

        // Ajouter le prix local pour le pays de l'utilisateur
        if ($user && $user->pays) {
            $numbers = array_map(function ($num) use ($user) {
                $num['price_local'] = $this->currencyService->convertUsdToLocal((float)($num['price'] ?? 0), $user->pays);
                $num['currency'] = $user->pays->currency_code;
                return $num;
            }, $numbers);
        }

        return response()->json([
            'success' => true,
            'provider' => config('services.numbers.default_provider'),
            'numbers' => $numbers
        ]);
    }

    // 2. Acheter un numéro choisi
    public function buy(Request $request)
    {
        $request->validate([
            'phone_number' => 'required|string',
            'country' => 'required|string|size:2',
        ]);

        $user = Auth::user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non authentifié.'], 401);
        }

        // --- ÉTAPE A : Vérification du Plan et du Quota ---
        $maxNumbers = $user->planMaxNumbers();
        $currentNumbersCount = $user->userNumbers()->where('status', 'active')->count();

        if ($maxNumbers > 0 && $currentNumbersCount >= $maxNumbers) {
            return response()->json([
                'success' => false,
                'message' => "Votre plan actuel limite à {$maxNumbers} numéros actifs."
            ], 403);
        }

        // --- ÉTAPE B : Recherche du prix auprès du fournisseur ---
        $provider = $this->providerManager->getProvider();
        $availableNumbers = $provider->searchNumbers($request->country, 'whatsapp');

        $selectedNumber = collect($availableNumbers)->firstWhere('number', $request->phone_number);

        if (! $selectedNumber) {
            return response()->json(['success' => false, 'message' => 'Numéro indisponible ou invalide.'], 404);
        }

        $price = (float) ($selectedNumber['price'] ?? 0);

        // --- ÉTAPE C : Vérification du solde ---
        if ($user->balance < $price) {
            return response()->json([
                'success' => false,
                'message' => "Solde insuffisant. Il vous manque " . ($price - $user->balance) . " $."
            ], 402);
        }

        // --- ÉTAPE D : Transaction Atomique ---
        try {
            return DB::transaction(function () use ($user, $provider, $request, $selectedNumber, $price) {
                // 1. Appel au fournisseur pour l'achat réel
                $result = $provider->purchaseNumber(
                    $request->phone_number,
                    $request->country
                );

                if (! $result['success']) {
                    throw new \Exception($result['message'] ?? 'Échec de l\'achat chez le fournisseur.');
                }

                // 2. Débit du solde utilisateur
                $user->decrement('balance', $price);

                // 3. Enregistrement de la transaction financière
                $user->transactions()->create([
                    'type_transaction_id' => \App\Models\TypeTransaction::where('code', 'number')->first()?->id,
                    'amount' => $price,
                    'currency' => $user->pays->currency_code ?? 'USD',
                    'status' => 'paid',
                    'description' => 'Achat du numéro ' . $request->phone_number,
                    'paid_at' => now(),
                ]);

                // 4. Enregistrement du numéro en base de données
                $userNumber = UserNumber::create([
                    'user_id' => $user->id,
                    'plan_id' => $user->activeSubscription()?->plan_id,
                    'phone_number' => $request->phone_number,
                    'country_code' => $request->country,
                    'provider' => config('services.numbers.default_provider'),
                    'provider_number_id' => $result['data']['numberId'] ?? null,
                    'status' => 'active',
                    'price' => $price,
                    'purchased_at' => now(),
                ]);

                return response()->json([
                    'success' => true,
                    'message' => 'Numéro activé et lié à votre compte avec succès !',
                    'data' => [
                        'number' => $userNumber->phone_number,
                        'remaining_balance' => $user->fresh()->balance,
                        'user_number_id' => $userNumber->id
                    ]
                ]);
            });
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la finalisation de l\'achat : ' . $e->getMessage(),
            ], 500);
        }
    }

    // 3. Liste des numéros de l'utilisateur
    public function myNumbers(Request $request)
    {
        $user = Auth::user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non authentifié.'], 401);
        }

        $numbers = $user->userNumbers()
            ->with('plan')
            ->orderBy('purchased_at', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'numbers' => $numbers
        ]);
    }

    // 4. Liste des messages reçus
    public function myMessages(Request $request)
    {
        $user = Auth::user();
        if (! $user) {
            return response()->json(['success' => false, 'message' => 'Utilisateur non authentifié.'], 401);
        }

        $messages = \App\Models\SmsMessage::whereHas('userNumber', function ($query) use ($user) {
            $query->where('user_id', $user->id);
        })
        ->orderBy('received_at', 'desc')
        ->paginate(20);

        return response()->json([
            'success' => true,
            'messages' => $messages
        ]);
    }
}
