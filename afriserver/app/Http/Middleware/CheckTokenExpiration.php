<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckTokenExpiration
{
    /**
     * Handle an incoming request.
     *
     * @param  Closure(Request): (Response)  $next
     */
   public function handle(Request $request, Closure $next): Response
{
    $user = $request->user();
    $token = $user?->currentAccessToken();

    if ($token && $user->tokenCan('access-api') && $token->created_at->addDay()->isPast()) {
        $token->delete();

        return response()->json([
            'success' => false,
            'message' => 'Token expiré.',
        ], 401);
    }

    return $next($request);
}
}
