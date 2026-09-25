<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\DeviceResource;
use App\Http\Responses\ApiResponse;
use App\Models\Device;
use App\Models\DeviceTokenFcm;
use App\Models\SessionUser;
use App\Services\ObservabilityService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceController extends Controller
{
    public function __construct(
        private readonly ObservabilityService $observability,
    ) {}
    /**
     * Liste les appareils liés au compte authentifié.
     */
    public function index(Request $request): JsonResponse
    {
        $devices = Device::query()
            ->where('user_id', $request->user()->id)
            ->when(
                ! $request->boolean('include_inactive'),
                fn ($q) => $q->where('actif', true)
            )
            ->with(['platform', 'sessionUser'])
            ->orderByDesc('last_used_at')
            ->orderByDesc('id')
            ->get();

        return ApiResponse::success(null, [
            'devices' => DeviceResource::collection($devices),
        ]);
    }

    /**
     * Déconnecte un appareil du compte (révoque session + tokens).
     */
    public function destroy(Request $request, Device $device): JsonResponse
    {
        $user = $request->user();

        if ((int) $device->user_id !== (int) $user->id) {
            return ApiResponse::error('Appareil introuvable.', null, 404);
        }

        $before = $this->deviceSnapshot($device);

        $this->revokeDevice($device);
        $device->refresh();

        $isCurrent = $request->header('X-Device-Id')
            && hash_equals((string) $device->identifier, (string) $request->header('X-Device-Id'));

        $this->observability->action(
            category: 'device',
            action: 'devices.disconnect',
            message: 'Appareil déconnecté',
            context: [
                'revoked_device_id' => $device->id,
                'revoked_identifier' => $device->identifier,
                'is_current' => $isCurrent,
            ],
            dataBefore: $before,
            dataAfter: $this->deviceSnapshot($device),
            user: $user,
            request: $request,
        );

        return ApiResponse::success(
            $isCurrent
                ? 'Cet appareil a été déconnecté. Veuillez vous reconnecter.'
                : 'Appareil déconnecté avec succès.'
        );
    }

    /**
     * Déconnecte tous les autres appareils (garde l'appareil courant).
     */
    public function destroyOthers(Request $request): JsonResponse
    {
        $user = $request->user();
        $currentIdentifier = $request->header('X-Device-Id');

        $query = Device::query()
            ->where('user_id', $user->id)
            ->where('actif', true);

        if ($currentIdentifier) {
            $query->where('identifier', '!=', $currentIdentifier);
        }

        $devices = $query->get();
        $before = $devices->map(fn (Device $d) => $this->deviceSnapshot($d))->values()->all();
        $count = 0;

        foreach ($devices as $device) {
            $this->revokeDevice($device);
            $count++;
        }

        $after = $devices->map(function (Device $d) {
            $d->refresh();

            return $this->deviceSnapshot($d);
        })->values()->all();

        $this->observability->action(
            category: 'device',
            action: 'devices.disconnect_others',
            message: "{$count} autre(s) appareil(s) déconnecté(s)",
            context: [
                'revoked_count' => $count,
                'kept_identifier' => $currentIdentifier,
            ],
            dataBefore: ['devices' => $before],
            dataAfter: ['devices' => $after],
            user: $user,
            request: $request,
        );

        return ApiResponse::success(
            $count === 0
                ? 'Aucun autre appareil à déconnecter.'
                : "{$count} appareil(s) déconnecté(s)."
            ,
            ['revoked_count' => $count]
        );
    }

    private function revokeDevice(Device $device): void
    {
        $device->update(['actif' => false]);

        SessionUser::query()
            ->where('device_id', $device->id)
            ->update(['is_active' => false]);

        DeviceTokenFcm::query()
            ->where('device_id', $device->id)
            ->update(['actif' => false]);

        $deviceName = $device->name ?: 'api';

        if ($device->user) {
            $device->user->tokens()
                ->where(function ($query) use ($deviceName): void {
                    $query->where('name', $deviceName.'-access')
                        ->orWhere('name', $deviceName.'-refresh');
                })
                ->delete();
        }
    }

    /**
     * @return array<string, mixed>
     */
    private function deviceSnapshot(Device $device): array
    {
        $session = $device->sessionUser;

        return [
            'id' => $device->id,
            'identifier' => $device->identifier,
            'name' => $device->name,
            'type' => $device->type,
            'os' => $device->os,
            'model' => $device->model,
            'actif' => (bool) $device->actif,
            'last_used_at' => $device->last_used_at?->toIso8601String(),
            'session_active' => $session ? (bool) $session->is_active : null,
            'fcm_active' => DeviceTokenFcm::query()
                ->where('device_id', $device->id)
                ->where('actif', true)
                ->exists(),
        ];
    }
}
