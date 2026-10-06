<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Profile;
use App\Models\TypeNotification;
use App\Models\User;
use App\Services\FcmNotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;
use Throwable;

// 🚀 Pour suivre les erreurs dans les logs de Render

class ProfileVerificationController extends Controller
{
    private static function secret(): string
    {
        $secret = config('services.internal.secret');

        if (! is_string($secret) || $secret === '') {
            Log::critical('services.internal.secret est vide : requêtes internes refusées.');
            abort(500, 'Configuration serveur invalide.');
        }

        return $secret;
    }

    private static function signatureValide(string $donnees, ?string $signatureRecue): bool
    {
        return $signatureRecue
            && hash_equals(hash_hmac('sha256', $donnees, self::secret()), $signatureRecue);
    }

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

            if ($profilExistant && $profilExistant->blocksNewVerification()) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Une vérification est déjà en cours ou votre compte est déjà approuvé.',
                    'profile_id' => $profilExistant->id,
                    'profile_status' => $profilExistant->status,
                ], 409);
            }

            // 3. Initialisation ou réinitialisation du ticket de profil (les anciens documents sont effacés)
            $profil = Profile::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'status' => Profile::STATUS_EN_ATTENTE_D_UPLOAD,
                    'document_url' => null,
                    'documents' => null,
                    'rejection_reason' => null,
                ]
            );

            // 4. Renvoi du feu vert et de l'ID unique au Mobile
            return response()->json([
                'statut' => 'autorise',
                'profile_id' => $profil->id,
                'profile_status' => $profil->status,
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
     * Statut KYC du profil de l'utilisateur connecté (reprise app / écran d'attente).
     */
    public function statutVerification(Request $request)
    {
        $user = Auth::user();

        if (! $user) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Utilisateur non authentifié.',
            ], 401);
        }

        $profil = Profile::where('user_id', $user->id)->first();

        if (! $profil) {
            return response()->json([
                'statut' => 'aucun',
                'profile_id' => null,
                'profile_status' => null,
                'status_valide' => $user->status_valide,
            ], 200);
        }

        return response()->json([
            'statut' => $profil->status,
            'profile_id' => $profil->id,
            'profile_status' => $profil->status,
            'status_valide' => $user->status_valide,
        ], 200);
    }

    /**
     * Statut d'un dossier KYC (propriétaire uniquement).
     */
    public function statutVerificationParId(Request $request, string $profile_id)
    {
        $user = Auth::user();

        if (! $user) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Utilisateur non authentifié.',
            ], 401);
        }

        $profil = Profile::where('id', $profile_id)
            ->where('user_id', $user->id)
            ->first();

        if (! $profil) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Dossier de vérification introuvable.',
            ], 404);
        }

        return response()->json([
            'statut' => $profil->status,
            'profile_id' => $profil->id,
            'profile_status' => $profil->status,
            'status_valide' => $user->status_valide,
        ], 200);
    }

    /**
     * Étape 2 : Express appelle cette route dès que les documents sont compressés et stockés.
     * Laravel enregistre les chemins, passe le statut en "vérification en cours" puis déclenche n8n.
     */
    public function notifierUploadTermine(Request $request)
    {
        try {
            // 🔒 COUCHE DE SÉCURITÉ : Vérification de la signature HMAC SHA-256
            // Si la signature est absente ou ne correspond pas au contenu, on bloque direct !
            if (! self::signatureValide($request->getContent(), $request->header('X-Signature'))) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Requête non autorisée ou signature cryptographique invalide.',
                ], 403);
            }

            // 1. Validation des données envoyées par Express
            $request->validate([
                'profile_id' => 'required|string|uuid|exists:profiles,id',
                'documents' => 'required|array|size:3',
                'documents.*.champ' => 'required|string|distinct|in:photopath,pieceavantpath,piecearrierepath',
                'documents.*.path' => 'required|string',
            ]);

            $profil = Profile::find($request->profile_id);

            // 2. Garde-fou : un profil déjà approuvé / en vérif / rejeté non réouvert
            //    ne peut pas être écrasé via Express (seul en_attente_d_upload est accepté).
            if ($profil->status !== Profile::STATUS_EN_ATTENTE_D_UPLOAD) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Ce profil n\'accepte plus d\'upload. Relancez /verifier/init si le statut le permet.',
                ], 409);
            }

            // 3. Sécurité : chaque chemin doit appartenir à CE profil
            foreach ($request->documents as $doc) {
                if (! str_starts_with($doc['path'], $profil->id.'/') || str_contains($doc['path'], '..')) {
                    return response()->json([
                        'statut' => 'refuse',
                        'erreur' => 'Chemin de document invalide.',
                    ], 422);
                }
            }

            // 4. Enregistrement des documents et mise à jour du statut
            $profil->documents = $request->documents;
            $profil->status = Profile::STATUS_EN_COURS_DE_VERIFICATION;
            $profil->save();

            // 5. Déclenchement de n8n APRÈS l'envoi de la réponse à Express
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
        $url = config('services.internal.n8n_url');

        if (! $url) {
            Log::error('N8N_WEBHOOK_URL manquant : n8n non déclenché pour le profil '.$profileId);

            return;
        }

        $payload = json_encode(['profile_id' => $profileId]);
        $signature = hash_hmac('sha256', $payload, self::secret());

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
     * Étape 3 : n8n récupère les infos user et les liens temporaires des documents.
     * Sécurité : HMAC SHA-256 du profile_id (pas de body sur un GET).
     */
    public function show(Request $request, string $profile_id)
    {
        try {
            // 🔒 Même secret que Express, mais on signe le profile_id (GET sans body)
            if (! self::signatureValide($profile_id, $request->header('X-Signature'))) {
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

            // Liens temporaires (10 minutes) vers les documents stockés sur Storj
            $documents = [];
            foreach ($profile->documents ?? [] as $doc) {
                try {
                    $documents[$doc['champ']] = Storage::disk('storj')->temporaryUrl(
                        $doc['path'],
                        now()->addMinutes(10)
                    );
                } catch (\Exception $e) {
                    Log::error('Lien temporaire impossible pour '.$doc['path'].' : '.$e->getMessage());
                }
            }

            return response()->json([
                'statut' => 'succes',
                'data' => [
                    'id' => $profile->id,
                    'name' => $profile->user->name,
                    'first_name' => $profile->user->first_name,
                    'documents' => $documents,
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
            $profileIdRecu = (string) $request->input('profile_id');

            if (! self::signatureValide($profileIdRecu, $request->header('X-Signature'))) {
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

            // 🛡️ Anti-rejeu : on n'accepte un verdict auto que si le profil est encore en vérif auto
            if ($profil->status !== Profile::STATUS_EN_COURS_DE_VERIFICATION) {
                return response()->json([
                    'statut' => 'refuse',
                    'erreur' => 'Ce profil n\'attend plus de verdict.',
                ], 409);
            }

            // Mapping des statuts n8n vers tes statuts de base de données
            $statutMapping = [
                'approved' => Profile::STATUS_APPROUVE,
                'rejected' => Profile::STATUS_REJETE,
                // Revue humaine : statut dédié — seul le dashboard pourra trancher ensuite
                'manual_review' => Profile::STATUS_VALIDATION_MANUELLE,
            ];

            $profil->status = $statutMapping[$request->kyc_status];

            // Optionnel : Sauvegarde le motif du refus ou de la mise en revue si ta table possède cette colonne
            if ($request->filled('reason') && Schema::hasColumn('profiles', 'rejection_reason')) {
                $profil->rejection_reason = $request->reason;
            }

            $profil->save();

            // Synchronise le compte utilisateur quand le KYC est tranché
            if ($request->kyc_status === 'approved') {
                $profil->user?->update(['status_valide' => 'valide']);
            } elseif ($request->kyc_status === 'rejected') {
                $profil->user?->update(['status_valide' => 'non_valide']);
            }

            // 🧹 3 bis. Décision prise : suppression des documents (pas en revue manuelle)
            if (in_array($request->kyc_status, ['approved', 'rejected'], true)) {
                $profil->clearStoredDocuments();
            }

            // 📢 4. Notifications push utilisateur (FCM)
            $this->notifierVerdictKyc(
                $profil,
                (string) $request->kyc_status,
                $request->input('title'),
                $request->input('message'),
                $request->input('reason'),
            );

            if ($request->kyc_status === 'manual_review' && $request->has('url_selfie')) {
                Log::info("🟡 ALERTE ÉQUIPE - Profil {$profil->id} soumis à vérification humaine. Motif : ".$request->reason);
                // TODO: Envoyer un e-mail à l'administration ou un webhook vers ton outil interne
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

    /**
     * Envoie une notification push à l'utilisateur selon le verdict KYC.
     * L'échec FCM ne doit jamais faire échouer le verdict déjà persisté.
     */
    private function notifierVerdictKyc(
        Profile $profil,
        string $kycStatus,
        ?string $title,
        ?string $message,
        ?string $reason,
    ): void {
        $payloads = [
            'approved' => [
                'type' => TypeNotification::CODE_KYC_APPROVED,
                'title' => $title ?: 'Identité vérifiée',
                'body' => $message ?: 'Votre vérification d\'identité a été approuvée.',
            ],
            'rejected' => [
                'type' => TypeNotification::CODE_KYC_REJECTED,
                'title' => $title ?: 'Vérification refusée',
                'body' => $message ?: ($reason ?: 'Votre vérification d\'identité a été refusée.'),
            ],
            'manual_review' => [
                'type' => TypeNotification::CODE_KYC_MANUAL_REVIEW,
                'title' => $title ?: 'Vérification en cours',
                'body' => $message ?: 'Votre dossier est en cours d\'examen par notre équipe.',
            ],
        ];

        if (! isset($payloads[$kycStatus])) {
            return;
        }

        $user = $profil->user;
        if (! $user instanceof User) {
            Log::warning('Impossible d\'envoyer la notif KYC : utilisateur introuvable.', [
                'profile_id' => $profil->id,
            ]);

            return;
        }

        $payload = $payloads[$kycStatus];

        try {
            app(FcmNotificationService::class)->sendToUser(
                $user,
                $payload['title'],
                $payload['body'],
                [
                    'type' => $payload['type'],
                    'profile_id' => $profil->id,
                    'kyc_status' => $kycStatus,
                    'reason' => $reason,
                ],
            );
        } catch (Throwable $e) {
            Log::error('Échec notification FCM après verdict KYC', [
                'profile_id' => $profil->id,
                'user_id' => $user->id,
                'kyc_status' => $kycStatus,
                'error' => $e->getMessage(),
            ]);
        }
    }
}
