<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Validation\ValidationException;

// 🚀 Pour suivre les erreurs dans les logs de Render

class ProfileVerificationController extends Controller
{
    /**
     * Étape 1 : Le Mobile demande à démarrer l'upload.
     * Génère l'ID unique (UUID) et prépare le ticket de profil.
     */
    public function initialiserVerification(Request $request)
    {
        try {
            // 1. Récupération de l'utilisateur connecté via le jeton mobile
            $user = Auth::user();

            if (! $user) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Utilisateur non authentifié.',
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

            // 3. Initialisation ou réinitialisation du ticket de profil (les anciens documents sont effacés)
            $profil = Profile::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'status' => 'en_attente_d_upload',
                    'document_url' => null,
                    'documents' => null,
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
            Log::error('Erreur lors de l\'initialisation du profil UUID : '.$e->getMessage());

            return response()->json([
                'statut' => 'erreur',
                'erreur' => 'Impossible d\'ouvrir un ticket de validation. Problème technique temporaire.',
            ], 500);
        }
    }

    /**
     * Étape 2 : Express appelle cette route dès que les documents sont compressés et stockés.
     * Laravel enregistre les chemins, passe le statut en "vérification en cours" puis déclenche n8n.
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
            if (! $signatureRecue || ! hash_equals($signatureAttendue, $signatureRecue)) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Requête non autorisée ou signature cryptographique invalide.',
                ], 403);
            }

            // 1. Validation des données envoyées par Express
            $request->validate([
                'profile_id' => 'required|string|uuid|exists:profiles,id',
                'documents' => 'required|array|size:3',
                'documents.*.champ' => 'required|string|in:photopath,pieceavantpath,piecearrierepath',
                'documents.*.path' => 'required|string',
            ]);

            $profil = Profile::find($request->profile_id);

            // 2. Sécurité : chaque chemin doit appartenir à CE profil
            foreach ($request->documents as $doc) {
                if (! str_starts_with($doc['path'], $profil->id.'/') || str_contains($doc['path'], '..')) {
                    return response()->json([
                        'statut' => 'refuse',
                        'erreur' => 'Chemin de document invalide.',
                    ], 422);
                }
            }

            // 3. Enregistrement des documents et mise à jour du statut
            $profil->documents = $request->documents;
            $profil->status = 'en_cours_de_verification';
            $profil->save();

            // 4. Déclenchement de n8n APRÈS l'envoi de la réponse à Express
            $profileId = $profil->id;
            dispatch(static function () use ($profileId) {
                self::declencherN8n($profileId);
            })->afterResponse();

            return response()->json([
                'statut' => 'succes',
                'message' => 'Documents enregistrés. Laravel attend désormais le verdict final de n8n.',
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Données envoyées par Express invalides ou ID introuvable.',
                'details' => $e->errors(),
            ], 422);

        } catch (\Exception $e) {
            Log::error('Erreur lors de la notification d\'upload Express : '.$e->getMessage());

            return response()->json([
                'statut' => 'erreur',
                'erreur' => 'Erreur interne lors de la mise à jour du statut.',
            ], 500);
        }
    }

    /**
     * Appelle le webhook n8n avec un body signé (HMAC SHA-256).
     * n8n peut être en veille sur Render : on laisse du temps et on réessaie.
     */
    private static function declencherN8n(string $profileId): void
    {
        $url = env('N8N_WEBHOOK_URL');

        if (! $url) {
            Log::error('N8N_WEBHOOK_URL manquant : n8n non déclenché pour le profil '.$profileId);

            return;
        }

        $payload = json_encode(['profile_id' => $profileId]);
        $signature = hash_hmac('sha256', $payload, env('SERVICE_SECRET_KEY'));

        try {
            Http::timeout(60)
                ->retry(3, 3000)
                ->withHeaders(['X-Signature' => $signature])
                ->withBody($payload, 'application/json')
                ->post($url);
        } catch (\Exception $e) {
            Log::error('Impossible de déclencher n8n pour le profil '.$profileId.' : '.$e->getMessage());
        }
    }

    /**
     * Étape 3 : n8n récupère les infos user liées au profile_id.
     * Sécurité : HMAC SHA-256 du profile_id (pas de body sur un GET).
     */
    public function show(Request $request, string $profile_id)
    {
        try {
            // 🔒 Même secret que Express, mais on signe le profile_id (GET sans body)
            $secret = env('SERVICE_SECRET_KEY');
            $signatureAttendue = hash_hmac('sha256', $profile_id, $secret);
            $signatureRecue = $request->header('X-Signature');

            if (! $signatureRecue || ! hash_equals($signatureAttendue, $signatureRecue)) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Requête non autorisée ou signature cryptographique invalide.',
                ], 403);
            }

            $profile = Profile::with('user')->find($profile_id);

            if (! $profile || ! $profile->user) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Profil introuvable.',
                ], 404);
            }

            return response()->json([
                'statut' => 'succes',
                'data' => [
                    'id' => $profile->id,
                    'name' => $profile->user->name,
                    'first_name' => $profile->user->first_name,
                ],
            ], 200);
        } catch (\Exception $e) {
            Log::error('Erreur lors de la récupération du profil pour n8n : '.$e->getMessage());

            return response()->json([
                'statut' => 'erreur',
                'erreur' => 'Erreur interne lors de la récupération du profil.',
            ], 500);
        }
    }

    public function traiterVerdictN8N(Request $request)
    {
        try {
            // 🔐 1. Validation de la signature cryptographique SHA-256
            $secret = env('SERVICE_SECRET_KEY');
            $body = $request->getContent();
            $signatureAttendue = hash_hmac('sha256', $body, $secret);
            $signatureRecue = $request->header('X-Signature');

            if (! $signatureRecue || ! hash_equals($signatureAttendue, $signatureRecue)) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Signature invalide. Requête non autorisée.',
                ], 403);
            }

            // 🔍 2. Validation des champs transmis dans le body par n8n
            $request->validate([
                'profile_id' => 'required|string|exists:profiles,id',
                'kyc_status' => 'required|string|in:approved,rejected,manual_review',
                'reason' => 'nullable|string',
                'title' => 'nullable|string',
                'message' => 'nullable|string',
            ]);

            // 🗄️ 3. Mise à jour du profil en Base de Données
            $profil = Profile::find($request->profile_id);

            // Mapping des statuts n8n vers tes statuts de base de données
            $statutMapping = [
                'approved' => 'approuve',
                'rejected' => 'rejete',
                'manual_review' => 'en_cours_de_verification', // Reste en traitement si vérification humaine requise
            ];

            $profil->status = $statutMapping[$request->kyc_status];

            // Optionnel : Sauvegarde le motif du refus ou de la mise en revue si ta table possède cette colonne
            if ($request->filled('reason') && Schema::hasColumn('profiles', 'rejection_reason')) {
                $profil->rejection_reason = $request->reason;
            }

            $profil->save();

            // 📢 4. Traitement des Notifications (Selon le statut)
            switch ($request->kyc_status) {
                case 'approved':
                    // TODO: Déclencher l'envoi du mail de succès ou notification Push
                    Log::info("🟢 Profil {$profil->id} approuvé automatiquement par n8n.");
                    break;

                case 'rejected':
                    // TODO: Envoyer la notification de rejet avec le motif précis ($request->message)
                    Log::warning("🔴 Profil {$profil->id} rejeté par n8n. Motif : ".$request->reason);
                    break;

                case 'manual_review':
                    // Si la règle "Alerter l'équipe" est déclenchée
                    if ($request->has('url_selfie')) {
                        Log::info("🟡 ALERTE ÉQUIPE - Profil {$profil->id} soumis à vérification humaine. Motif : ".$request->reason);
                        // TODO: Envoyer un e-mail à l'administration ou un webhook vers ton outil interne
                    } else {
                        Log::info("🟡 Profil {$profil->id} placé en file d'attente de revue manuelle.");
                    }
                    break;
            }

            return response()->json([
                'statut' => 'succes',
                'message' => 'Verdict KYC traité avec succès par Laravel.',
            ], 200);

        } catch (ValidationException $e) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Format de données incorrect.',
                'details' => $e->errors(),
            ], 422);
        } catch (\Exception $e) {
            Log::error('❌ Erreur lors du traitement du verdict n8n : '.$e->getMessage());

            return response()->json([
                'statut' => 'erreur',
                'erreur' => 'Erreur interne lors du traitement du verdict.',
            ], 500);
        }
    }
}