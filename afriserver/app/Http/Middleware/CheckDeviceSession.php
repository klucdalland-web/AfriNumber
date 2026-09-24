<?php

namespace App\Http\Middleware;

use App\Models\Device;
use App\Models\SessionUser;
use App\Services\GeoLocationService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class CheckDeviceSession
{
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        if (! $user) {
            return $next($request);
        }

        $deviceId = $request->header('X-Device-Id');

        if (! $deviceId) {
            return response()->json([
                'message' => "Votre appareil n'a pas été identifié. Merci de vous reconnecter.",
            ], 403);
        }


        $session = Device::query()
            ->where('user_id', $user->id)
            ->where('identifier', $deviceId)
            ->first();


        if (! $session) {
            return response()->json([
                'message' => 'Appareil non reconnu. Veuillez vous reconnecter.',
            ], 403);
        }

        $session=SessionUser::query()
            ->where('device_id', $session->id)
            ->where('user_id', $user->id)
            ->first();

        if (! $session->is_active) {
            return response()->json([
                'message' => 'Votre appareil a été déconnecté. Veuillez vous reconnecter pour continuer.',
            ], 403);
        }

        // Rafraîchit les infos géo/activité, une fois par minute maximum
        if ($session->updated_at === null || $session->updated_at->diffInMinutes(now()) >= 1) {
            $ip = $this->getClientIp($request);
            $geoService = new GeoLocationService();
            $geo = $geoService->getGeoFromIp($ip);

            $session->update([
                'ip_address' => $ip,
                'user_agent' => $request->userAgent(),
                'country' => $geo['country'] ?? $session->country,
                'city' => $geo['city'] ?? null,
                'region' => $geo['region'] ?? null,
                'timezone' => $geo['timezone'] ?? null,
                'latitude' => $geo['latitude'] ?? null,
                'internet_provider' => $geo['internet_provider'] ?? null,
                'network_type' => $geo['network_type'] ?? null,
            ]);
        }

        return $next($request);
    }

    private function getClientIp(Request $request): string
    {
        $ip = $request->header('CF-Connecting-IP')
            ?? $request->header('X-Real-IP')
            ?? $request->header('X-Forwarded-For');

        if ($ip && str_contains($ip, ',')) {
            $ip = trim(explode(',', $ip)[0]);
        }

        return $ip ?: $request->ip();
    }
}