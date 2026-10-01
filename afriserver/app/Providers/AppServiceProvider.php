<?php

namespace App\Providers;

use App\Filament\Commands\MakeUserCommand as AppMakeUserCommand;
use App\Policies\RolePolicy;
use Filament\Commands\MakeUserCommand as FilamentMakeUserCommand;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Routing\UrlGenerator;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Spatie\Permission\Models\Role;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->bind(FilamentMakeUserCommand::class, AppMakeUserCommand::class);
    }

    public function boot(UrlGenerator $url): void
    {
        Gate::policy(Role::class, RolePolicy::class);

        Gate::before(function ($user, string $ability, array $arguments = []): ?bool {
            if (! method_exists($user, 'hasRole') || ! $user->hasRole('super_admin')) {
                return null;
            }

            if (
                $ability === 'delete'
                && ($arguments[0] ?? null) instanceof Role
                && $arguments[0]->name === 'super_admin'
            ) {
                return false;
            }

            return true;
        });

        if ($this->app->environment('production')) {
            $url->forceScheme('https');
        }

        RateLimiter::for('login', function (Request $request) {
            $key = $request->ip();

            return Limit::perMinute(20)->by($key)->response(function () use ($key) {
                $retryAfter = RateLimiter::availableIn(md5('login'.$key));

                return response()->json([
                    'success' => false,
                    'message' => 'Trop de tentatives de connexion depuis cette adresse. Veuillez réessayer dans '.$retryAfter.' secondes.',
                    'retry_after' => $retryAfter,
                ], 429);
            });
        });

        RateLimiter::for('register', function (Request $request) {
            $key = $request->ip();

            return Limit::perMinute(3)->by($key)->response(function () use ($key) {
                $retryAfter = RateLimiter::availableIn(md5('register'.$key));

                return response()->json([
                    'success' => false,
                    'message' => 'Trop de tentatives d\'inscription. Veuillez réessayer dans '.$retryAfter.' secondes.',
                    'retry_after' => $retryAfter,
                ], 429);
            });
        });
    }
}
