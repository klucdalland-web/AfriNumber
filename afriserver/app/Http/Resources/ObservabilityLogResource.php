<?php

namespace App\Http\Resources;

use App\Models\ObservabilityLog;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ObservabilityLog
 */
class ObservabilityLogResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'category' => $this->category,
            'action' => $this->action,
            'level' => $this->level,
            'message' => $this->message,
            'method' => $this->method,
            'path' => $this->path,
            'route_name' => $this->route_name,
            'status_code' => $this->status_code,
            'ip_address' => $this->ip_address,
            'device_identifier' => $this->device_identifier,
            'device_id' => $this->device_id,
            'duration_ms' => $this->duration_ms,
            'request_payload' => $this->request_payload,
            'context' => $this->context,
            'data_before' => $this->data_before,
            'data_after' => $this->data_after,
            'session' => $this->session,
            'location' => $this->location,
            'error' => $this->error,
            'created_at' => $this->created_at?->toIso8601String(),
        ];
    }
}
