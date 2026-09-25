<?php

namespace App\Providers;

use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Routing\UrlGenerator;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        //
    }

    public function boot(UrlGenerator $url): void
    {
        if ($this->app->environment('production')) {
            $url->forceScheme('https');
        }

            RateLimiter::for('login', function (Request $request) {
                    $key = $request->ip();

                return Limit::perMinute(20)->by($key)->response(function () use ($key) {
                    $retryAfter = RateLimiter::availableIn(md5('login' . $key));

                    return response()->json([
                        'success' => false,
                        'message' => 'Trop de tentatives de connexion depuis cette adresse. Veuillez réessayer dans ' . $retryAfter . ' secondes.',
                        'retry_after' => $retryAfter,
                    ], 429);
                });
            });                     

        RateLimiter::for('register', function (Request $request) {
            $key = $request->ip();

            return Limit::perMinute(3)->by($key)->response(function () use ($key) {
                $retryAfter = RateLimiter::availableIn(md5('register' . $key));

                return response()->json([
                    'success' => false,
                    'message' => 'Trop de tentatives d\'inscription. Veuillez réessayer dans ' . $retryAfter . ' secondes.',
                    'retry_after' => $retryAfter,
                ], 429);
            });
        });
    }
}