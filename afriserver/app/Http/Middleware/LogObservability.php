<?php

namespace App\Http\Middleware;

use App\Services\ObservabilityService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class LogObservability
{
    public function __construct(
        private readonly ObservabilityService $observability,
    ) {}

    public function handle(Request $request, Closure $next): Response
    {
        $request->attributes->set('_observability_started_at', microtime(true));

        return $next($request);
    }

    public function terminate(Request $request, Response $response): void
    {
        // Évite de logger le endpoint de consultation de l'historique (bruit)
        if ($request->is('api/v1/observability*') || $request->is('api/v1/activity*')) {
            return;
        }

        $startedAt = (float) $request->attributes->get('_observability_started_at', microtime(true));

        $this->observability->http($request, $response, $startedAt);
    }
}
