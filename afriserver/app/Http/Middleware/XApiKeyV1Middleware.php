<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class XApiKeyV1Middleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $expectedApiKey = (string) env('X_API_KEY_V1', '');
        $providedApiKey = (string) $request->header('x-api-key', '');

        if ($expectedApiKey === '' || $providedApiKey === '' || ! hash_equals($expectedApiKey, $providedApiKey)) {
            return $this->unauthorizedResponse();
        }

        return $next($request);
    }

    private function unauthorizedResponse(): JsonResponse
    {
        return response()->json([
            'message' => 'Acces non autorise. Cle API invalide ou manquante.',
        ], 401);
    }
}