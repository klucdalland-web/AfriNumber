<?php

use App\Http\Middleware\CheckDeviceSession;
use App\Http\Middleware\CheckTokenExpiration;
use App\Http\Middleware\LogObservability;
use App\Http\Middleware\XApiKeyV1Middleware;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Laravel\Sanctum\Http\Middleware\CheckAbilities;
use Laravel\Sanctum\Http\Middleware\CheckForAnyAbility;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->validateCsrfTokens(except: [
            'api/v1/express/upload-complete',
        ]);

        $middleware->alias([
            'check.token.expiration' => CheckTokenExpiration::class,
            'abilities' => CheckAbilities::class,
            'ability' => CheckForAnyAbility::class,
            'x-api-key-v1' => XApiKeyV1Middleware::class,
            'check.device.session' => CheckDeviceSession::class,
            'observability' => LogObservability::class,
        ]);
        $middleware->redirectGuestsTo(function (Request $request): ?string {
            if ($request->is('api/*')) {
                return null;
            }

            return route('login');
        });
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );
    })->create();
