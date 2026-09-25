<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Services\ZavuService;
use Illuminate\Http\Request;

class NumberController extends Controller
{
    protected ZavuService $zavuService;

    public function __construct(ZavuService $zavuService)
    {
        $this->zavuService = $zavuService;
    }

    // 1. Rechercher des numéros
   public function search(Request $request)
{
    // On force la récupération et le passage en majuscules
    $country = strtoupper($request->input('country', 'US'));
    
    $numbers = $this->zavuService->searchAvailableNumbers($country);

    return response()->json([
        'success' => true,
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

        $result = $this->zavuService->purchaseNumber(
            $request->input('phone_number'),
            $request->input('country')
        );

        // ICI : Vous pourrez ajouter une ligne pour enregistrer le numéro dans Supabase 
        // lié à l'utilisateur connecté (ex: auth()->id())

        return response()->json([
            'success' => true,
            'message' => 'Numéro activé avec succès !',
            'data' => $result
        ]);
    }
}
