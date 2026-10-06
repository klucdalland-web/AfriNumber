<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\Notification\IndexNotificationRequest;
use App\Http\Resources\UserNotificationResource;
use App\Http\Responses\ApiResponse;
use App\Models\UserNotification;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

/**
 * Inbox notifications de l'utilisateur authentifié.
 *
 * Toutes les actions sont scopées à $request->user() (Sanctum access-api).
 */
class NotificationController extends Controller
{
    /**
     * Liste paginée des notifications du compte connecté.
     */
    public function index(IndexNotificationRequest $request): JsonResponse
    {
        $perPage = (int) $request->integer('per_page', 20);

        $query = UserNotification::query()
            ->forUser($request->user()->id)
            ->with('typeNotification')
            ->orderByDesc('created_at')
            ->orderByDesc('id');

        if ($request->boolean('unread')) {
            $query->unread();
        }

        $paginator = $query->paginate($perPage);

        return ApiResponse::success(
            $paginator->total() === 0
                ? 'Aucune notification.'
                : 'Notifications récupérées avec succès.',
            [
                'notifications' => UserNotificationResource::collection($paginator->items()),
                'meta' => [
                    'current_page' => $paginator->currentPage(),
                    'last_page' => $paginator->lastPage(),
                    'per_page' => $paginator->perPage(),
                    'total' => $paginator->total(),
                    'unread_count' => UserNotification::query()
                        ->forUser($request->user()->id)
                        ->unread()
                        ->count(),
                ],
            ]
        );
    }

    /**
     * Nombre de notifications non lues.
     */
    public function unreadCount(Request $request): JsonResponse
    {
        $count = UserNotification::query()
            ->forUser($request->user()->id)
            ->unread()
            ->count();

        return ApiResponse::success(null, [
            'unread_count' => $count,
        ]);
    }

    /**
     * Détail d'une notification appartenant à l'utilisateur connecté.
     */
    public function show(Request $request, int|string $notification): JsonResponse
    {
        $item = $this->findOwned($request, $notification);

        if ($item === null) {
            return ApiResponse::error('Notification introuvable.', null, 404);
        }

        $item->loadMissing('typeNotification');

        return ApiResponse::success('Notification récupérée avec succès.', [
            'notification' => UserNotificationResource::make($item),
        ]);
    }

    /**
     * Marque une notification comme lue.
     */
    public function markAsRead(Request $request, int|string $notification): JsonResponse
    {
        $item = $this->findOwned($request, $notification);

        if ($item === null) {
            return ApiResponse::error('Notification introuvable.', null, 404);
        }

        $item->markAsRead();
        $item->loadMissing('typeNotification');

        return ApiResponse::success('Notification marquée comme lue.', [
            'notification' => UserNotificationResource::make($item->fresh()),
        ]);
    }

    /**
     * Marque toutes les notifications de l'utilisateur comme lues.
     */
    public function markAllAsRead(Request $request): JsonResponse
    {
        $updated = UserNotification::query()
            ->forUser($request->user()->id)
            ->unread()
            ->update(['read_at' => now()]);

        return ApiResponse::success('Toutes les notifications ont été marquées comme lues.', [
            'updated' => $updated,
            'unread_count' => 0,
        ]);
    }

    /**
     * Supprime une notification de l'inbox (uniquement la sienne).
     */
    public function destroy(Request $request, int|string $notification): JsonResponse
    {
        $item = $this->findOwned($request, $notification);

        if ($item === null) {
            return ApiResponse::error('Notification introuvable.', null, 404);
        }

        $item->delete();

        return ApiResponse::success('Notification supprimée.');
    }

    private function findOwned(Request $request, int|string $notification): ?UserNotification
    {
        return UserNotification::query()
            ->forUser($request->user()->id)
            ->find($notification);
    }
}
