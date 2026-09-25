<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\ObservabilityLogResource;
use App\Http\Responses\ApiResponse;
use App\Models\ObservabilityLog;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ObservabilityController extends Controller
{
    /**
     * Historique d'activité du compte connecté.
     */
    public function index(Request $request): JsonResponse
    {
        $perPage = min(100, max(1, (int) $request->input('per_page', 30)));

        $logs = ObservabilityLog::query()
            ->where('user_id', $request->user()->id)
            ->when($request->filled('category'), fn ($q) => $q->where('category', $request->string('category')))
            ->when($request->filled('action'), fn ($q) => $q->where('action', $request->string('action')))
            ->when($request->filled('level'), fn ($q) => $q->where('level', $request->string('level')))
            ->when($request->filled('device_id'), fn ($q) => $q->where('device_id', $request->integer('device_id')))
            ->when(
                $request->filled('device_identifier'),
                fn ($q) => $q->where('device_identifier', $request->string('device_identifier'))
            )
            ->when($request->filled('from'), fn ($q) => $q->where('created_at', '>=', $request->date('from')))
            ->when($request->filled('to'), fn ($q) => $q->where('created_at', '<=', $request->date('to')->endOfDay()))
            ->orderByDesc('id')
            ->paginate($perPage);

        return ApiResponse::success(null, [
            'logs' => ObservabilityLogResource::collection($logs->items()),
            'pagination' => [
                'current_page' => $logs->currentPage(),
                'last_page' => $logs->lastPage(),
                'per_page' => $logs->perPage(),
                'total' => $logs->total(),
            ],
        ]);
    }
}
