<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\NotificationCampaignProcessor;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class ProcessNotificationCampaignsController extends Controller
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

    private static function signatureValide(string $payload, ?string $signatureRecue): bool
    {
        return is_string($signatureRecue)
            && $signatureRecue !== ''
            && hash_equals(hash_hmac('sha256', $payload, self::secret()), $signatureRecue);
    }

    public function __invoke(Request $request, NotificationCampaignProcessor $processor): JsonResponse
    {
        $payload = 'process-notification-campaigns';

        if (! self::signatureValide($payload, $request->header('X-Signature'))) {
            return response()->json([
                'statut' => 'refuse',
                'erreur' => 'Signature invalide. Requête non autorisée.',
            ], 403);
        }

        $limit = min(100, max(1, (int) $request->input('limit', 50)));
        $stats = $processor->process($limit);

        return response()->json([
            'statut' => 'ok',
            'stats' => $stats,
        ]);
    }
}
