<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Log; // 🚀 Pour suivre les erreurs dans les logs de Render

class ProfileVerificationController extends Controller
{
    /**
     * Étape 1 : Le Mobile demande à démarrer l'upload.
     * Génère l'ID unique (UUID) et prépare Supabase.
     */
    public function initialiserVerification(Request $request)
    {
        try {
            // 1. Récupération de l'utilisateur connecté via le jeton mobile
            $user = Auth::user();

            if (! $user) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Utilisateur non authentifié.'
                ], 401);
            }

            // 2. Sécurité : Vérifier si une validation n'est pas déjà en cours
            $profilExistant = Profile::where('user_id', $user->id)->first();

            if ($profilExistant && in_array($profilExistant->status, ['en_cours_de_verification', 'approuve'])) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Une vérification est déjà en cours ou votre compte est déjà approuvé.',
                ], 400);
            }

            // 3. Initialisation ou réinitialisation du ticket de profil dans Supabase (Génère l'UUID automatiquement via le modèle)
            $profil = Profile::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'status' => 'en_attente_d_upload',
                    'document_url' => null,
                ]
            );

            // 4. Renvoi du feu vert et de l'ID unique au Mobile
            return response()->json([
                'statut' => 'autorise',
                'profile_id' => $profil->id,
                'message' => 'Ticket de validation ouvert. Veuillez transmettre cet ID à Express lors de l\'upload.',
            ], 200);

        } catch (\Exception $e) {
            // 🚨 Journalise l'erreur en arrière-plan sur Render
            Log::error('Erreur lors de l\'initialisation du profil UUID : ' . $e->getMessage());

            return response()->json([
                'statut' => 'erreur',
                'erreur' => 'Impossible d\'ouvrir un ticket de validation. Problème technique temporaire.',
            ], 500);
        }
    }

    /**
     * Étape 2 : Express appelle cette route dès qu'il a fini sa compression flash.
     * Laravel passe le statut en "vérification en cours" en attendant n8n.
     */
    public function notifierUploadTermine(Request $request)
    {
        try {
            // 🔒 COUCHE DE SÉCURITÉ : Vérification de la signature HMAC SHA-256
            $secret = env('SERVICE_SECRET_KEY');
            $body = $request->getContent(); // Récupère le JSON brut envoyé par Express
            $signatureAttendue = hash_hmac('sha256', $body, $secret);
            $signatureRecue = $request->header('X-Signature');

            // Si la signature est absente ou ne correspond pas au contenu, on bloque direct !
            if (!$signatureRecue || !hash_equals($signatureAttendue, $signatureRecue)) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Requête non autorisée ou signature cryptographique invalide.'
                ], 403);
            }

            // 1. Validation classique des données (Format UUID)
            $request->validate([
                'profile_id' => 'required|string|uuid|exists:profiles,id',
            ]);

            // 2. Recherche du profil dans Supabase et mise à jour du statut
            $profil = Profile::find($request->profile_id);
            $profil->status = 'en_cours_de_verification';
            $profil->save();

            return response()->json([
                'statut' => 'succes',
                'message' => 'Statut mis à jour. Laravel attend désormais le verdict final de n8n.',
            ], 200);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Données envoyées par Express invalides ou ID introuvable.',
                'details' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur lors de la notification d\'upload Express : ' . $e->getMessage());
            return response()->json([
                'statut' => 'erreur',
                'erreur' => 'Erreur interne lors de la mise à jour du statut.',
            ], 500);
        }
    }

}
