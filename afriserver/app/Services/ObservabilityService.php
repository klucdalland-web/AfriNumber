<?php

namespace App\Services;

use App\Models\Device;
use App\Models\ObservabilityLog;
use App\Models\SessionUser;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;
use Throwable;

class ObservabilityService
{
    /** @var list<string> */
    private const SENSITIVE_KEYS = [
        'password',
        'password_confirmation',
        'current_password',
        'new_password',
        'code',
        'otp',
        'otp_code',
        'token',
        'access_token',
        'refresh_token',
        'fcm_token',
        'authorization',
        'x-api-key',
        'x_api_key',
        'api_key',
        'secret',
    ];

    /**
     * Log une action métier (auth, device, user, security…).
     *
     * @param  array<string, mixed>  $context
     * @param  array<string, mixed>|null  $payload
     * @param  array<string, mixed>|null  $dataBefore  État avant modification
     * @param  array<string, mixed>|null  $dataAfter   État après modification
     */
    public function action(
        string $category,
        string $action,
        ?string $message = null,
        array $context = [],
        ?array $payload = null,
        ?array $dataBefore = null,
        ?array $dataAfter = null,
        string $level = 'info',
        ?User $user = null,
        ?Request $request = null,
    ): void {
        $request ??= request();
        $deviceIdentifier = $this->resolveDeviceIdentifier($request);

        $this->write([
            'user_id' => $user?->id ?? $request?->user()?->id,
            'device_identifier' => $deviceIdentifier,
            'category' => $category,
            'action' => $action,
            'level' => $level,
            'message' => $message,
            'method' => $request?->method(),
            'path' => $request ? '/'.$request->path() : null,
            'route_name' => $request?->route()?->getName(),
            'ip_address' => $request ? $this->clientIp($request) : null,
            'user_agent' => $request?->userAgent(),
            'request_payload' => $payload !== null ? $this->sanitize($payload) : null,
            'context' => $context === [] ? null : $this->sanitize($context),
            'data_before' => $dataBefore !== null ? $this->sanitize($dataBefore) : null,
            'data_after' => $dataAfter !== null ? $this->sanitize($dataAfter) : null,
        ], $request);
    }

    /**
     * Log une requête HTTP (middleware).
     */
    public function http(Request $request, Response $response, float $startedAt): void
    {
        $routeName = $request->route()?->getName();
        $status = $response->getStatusCode();
        $category = $this->categoryFromRoute($routeName, $request->path());
        $action = $this->actionFromRoute($routeName, $request->method(), $request->path());

        $level = match (true) {
            $status >= 500 => 'error',
            $status >= 400 => 'warning',
            default => 'info',
        };

        $this->write([
            'user_id' => $request->user()?->id,
            'device_identifier' => $this->resolveDeviceIdentifier($request),
            'category' => $category,
            'action' => $action,
            'level' => $level,
            'message' => strtoupper($request->method()).' '.$request->path().' → '.$status,
            'method' => $request->method(),
            'path' => '/'.$request->path(),
            'route_name' => $routeName,
            'status_code' => $status,
            'ip_address' => $this->clientIp($request),
            'user_agent' => $request->userAgent(),
            'request_payload' => $this->sanitize($this->extractPayload($request)),
            'context' => [
                'query' => $this->sanitize($request->query()),
            ],
            'duration_ms' => (int) max(0, round((microtime(true) - $startedAt) * 1000)),
        ], $request);
    }

    /**
     * @param  array<string, mixed>  $attributes
     */
    private function write(array $attributes, ?Request $request = null): void
    {
        try {
            $deviceIdentifier = $attributes['device_identifier'] ?? null;
            $userId = $attributes['user_id'] ?? null;

            if ($deviceIdentifier && empty($attributes['device_id'])) {
                $deviceQuery = Device::query()->where('identifier', $deviceIdentifier);

                if ($userId) {
                    $deviceQuery->where('user_id', $userId);
                }

                $attributes['device_id'] = $deviceQuery->value('id');
            }

            $session = $this->resolveSessionSnapshot(
                deviceId: isset($attributes['device_id']) ? (int) $attributes['device_id'] : null,
                userId: $userId ? (int) $userId : null,
            );

            if ($session !== null) {
                $attributes['session'] = $session;
            }

            $location = $this->resolveLocation(
                ip: isset($attributes['ip_address']) && is_string($attributes['ip_address'])
                    ? $attributes['ip_address']
                    : null,
                session: $session,
            );

            if ($location !== null) {
                $attributes['location'] = $location;
            }

            $attributes['created_at'] = now();

            ObservabilityLog::query()->create($attributes);
        } catch (Throwable $e) {
            // Ne jamais casser le flux métier à cause du logging
            Log::warning('Observability write failed', [
                'error' => $e->getMessage(),
                'action' => $attributes['action'] ?? null,
            ]);
        }
    }

    private function resolveDeviceIdentifier(?Request $request): ?string
    {
        if (! $request) {
            return null;
        }

        $fromHeader = $request->header('X-Device-Id');
        if (is_string($fromHeader) && $fromHeader !== '') {
            return $fromHeader;
        }

        $fromBody = $request->input('device_id');
        if (is_string($fromBody) && $fromBody !== '') {
            return $fromBody;
        }

        return null;
    }

    /**
     * @return array<string, mixed>|null
     */
    private function resolveSessionSnapshot(?int $deviceId, ?int $userId): ?array
    {
        if (! $deviceId) {
            return null;
        }

        $query = SessionUser::query()
            ->where('device_id', $deviceId)
            ->with('device:id,identifier,name,model,os_version,actif,last_used_at');

        if ($userId) {
            $query->where('user_id', $userId);
        }

        $session = $query->first();

        if (! $session) {
            return null;
        }

        return [
            'device_id' => $session->device_id,
            'user_id' => $session->user_id,
            'is_active' => (bool) $session->is_active,
            'ip_address' => $session->ip_address,
            'user_agent' => $session->user_agent,
            'country' => $session->country,
            'city' => $session->city,
            'region' => $session->region,
            'timezone' => $session->timezone,
            'latitude' => $session->latitude !== null ? (float) $session->latitude : null,
            'internet_provider' => $session->internet_provider,
            'network_type' => $session->network_type,
            'device' => $session->device ? [
                'id' => $session->device->id,
                'identifier' => $session->device->identifier,
                'name' => $session->device->name,
                'model' => $session->device->model,
                'os_version' => $session->device->os_version,
                'actif' => (bool) $session->device->actif,
                'last_used_at' => $session->device->last_used_at?->toIso8601String(),
            ] : null,
            'created_at' => $session->created_at?->toIso8601String(),
            'updated_at' => $session->updated_at?->toIso8601String(),
        ];
    }

    /**
     * Lieu de l'action : priorité session geo, sinon lookup IP (cache 24h).
     *
     * @param  array<string, mixed>|null  $session
     * @return array<string, mixed>|null
     */
    private function resolveLocation(?string $ip, ?array $session): ?array
    {
        if ($session && (($session['country'] ?? null) || ($session['city'] ?? null))) {
            return [
                'country' => $session['country'] ?? null,
                'city' => $session['city'] ?? null,
                'region' => $session['region'] ?? null,
                'timezone' => $session['timezone'] ?? null,
                'latitude' => $session['latitude'] ?? null,
                'longitude' => null,
                'internet_provider' => $session['internet_provider'] ?? null,
                'network_type' => $session['network_type'] ?? null,
                'source' => 'session',
                'ip' => $session['ip_address'] ?? $ip,
            ];
        }

        if (! $ip) {
            return null;
        }

        $geo = app(GeoLocationService::class)->getGeoFromIp($ip);

        $hasPlace = ($geo['country'] ?? null) || ($geo['city'] ?? null) || ($geo['region'] ?? null);

        if (! $hasPlace) {
            return [
                'country' => null,
                'city' => null,
                'region' => null,
                'timezone' => null,
                'latitude' => null,
                'longitude' => null,
                'internet_provider' => null,
                'network_type' => null,
                'source' => 'ip',
                'ip' => $ip,
                'unavailable' => true,
                'reason' => 'private_or_unknown_ip',
            ];
        }

        return [
            'country' => $geo['country'] ?? null,
            'city' => $geo['city'] ?? null,
            'region' => $geo['region'] ?? null,
            'timezone' => $geo['timezone'] ?? null,
            'latitude' => $geo['latitude'] ?? null,
            'longitude' => $geo['longitude'] ?? null,
            'internet_provider' => $geo['internet_provider'] ?? null,
            'network_type' => $geo['network_type'] ?? null,
            'source' => 'ip',
            'ip' => $ip,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function extractPayload(Request $request): array
    {
        if (in_array($request->method(), ['GET', 'HEAD', 'OPTIONS'], true)) {
            return [];
        }

        $payload = $request->except([
            ...self::SENSITIVE_KEYS,
        ]);

        // Limite la taille stockée
        $encoded = json_encode($payload);
        if ($encoded !== false && strlen($encoded) > 8000) {
            return ['_truncated' => true, '_bytes' => strlen($encoded)];
        }

        return $payload;
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    private function sanitize(array $data): array
    {
        $clean = [];

        foreach ($data as $key => $value) {
            $keyStr = is_string($key) ? $key : (string) $key;

            if ($this->isSensitiveKey($keyStr)) {
                $clean[$keyStr] = '[REDACTED]';
                continue;
            }

            if (is_array($value)) {
                $clean[$keyStr] = $this->sanitize($value);
                continue;
            }

            if (is_string($value) && strlen($value) > 2000) {
                $clean[$keyStr] = substr($value, 0, 2000).'…[truncated]';
                continue;
            }

            $clean[$keyStr] = $value;
        }

        return $clean;
    }

    private function isSensitiveKey(string $key): bool
    {
        $normalized = strtolower($key);

        foreach (self::SENSITIVE_KEYS as $sensitive) {
            if ($normalized === $sensitive || str_contains($normalized, $sensitive)) {
                return true;
            }
        }

        return false;
    }

    private function categoryFromRoute(?string $routeName, string $path): string
    {
        if ($routeName && str_contains($routeName, 'auth')) {
            return 'auth';
        }

        if ($routeName && str_contains($routeName, 'devices')) {
            return 'device';
        }

        if (str_contains($path, 'auth')) {
            return 'auth';
        }

        if (str_contains($path, 'devices')) {
            return 'device';
        }

        return 'request';
    }

    private function actionFromRoute(?string $routeName, string $method, string $path): string
    {
        if ($routeName) {
            return str_replace(['v1.', 'auth.'], ['', 'auth.'], $routeName);
        }

        return 'http.'.strtolower($method).'.'.trim(str_replace('/', '.', $path), '.');
    }

    private function clientIp(Request $request): string
    {
        $ip = $request->header('CF-Connecting-IP')
            ?? $request->header('X-Real-IP')
            ?? $request->header('X-Forwarded-For')
            ?? $request->ip();

        if (is_string($ip) && str_contains($ip, ',')) {
            $ip = trim(explode(',', $ip)[0]);
        }

        return is_string($ip) ? $ip : '0.0.0.0';
    }
}
