<?php

namespace App\Services;

use App\Models\Device;
use App\Models\ObservabilityLog;
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

        $this->write([
            'user_id' => $user?->id ?? $request?->user()?->id,
            'device_identifier' => $request?->header('X-Device-Id'),
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
            'device_identifier' => $request->header('X-Device-Id'),
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

            if ($deviceIdentifier && $userId && empty($attributes['device_id'])) {
                $attributes['device_id'] = Device::query()
                    ->where('user_id', $userId)
                    ->where('identifier', $deviceIdentifier)
                    ->value('id');
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
