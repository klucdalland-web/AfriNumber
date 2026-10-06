<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class UserNotification extends Model
{
    /**
     * @var list<string>
     */
    protected $fillable = [
        'user_id',
        'type_notification_id',
        'notification_campaign_id',
        'title',
        'body',
        'data',
        'read_at',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'data' => 'array',
            'read_at' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function typeNotification(): BelongsTo
    {
        return $this->belongsTo(TypeNotification::class);
    }

    public function campaign(): BelongsTo
    {
        return $this->belongsTo(NotificationCampaign::class, 'notification_campaign_id');
    }

    public function isRead(): bool
    {
        return $this->read_at !== null;
    }

    public function markAsRead(): void
    {
        if ($this->read_at !== null) {
            return;
        }

        $this->forceFill(['read_at' => now()])->save();
    }

    /**
     * @param  Builder<UserNotification>  $query
     * @return Builder<UserNotification>
     */
    public function scopeForUser(Builder $query, int $userId): Builder
    {
        return $query->where('user_id', $userId);
    }

    /**
     * @param  Builder<UserNotification>  $query
     * @return Builder<UserNotification>
     */
    public function scopeUnread(Builder $query): Builder
    {
        return $query->whereNull('read_at');
    }

    /**
     * Crée une notification inbox pour un utilisateur (push / campagne / système).
     *
     * @param  array<string, mixed>|null  $data
     */
    public static function createForUser(
        User $user,
        string $title,
        string $body,
        ?int $typeNotificationId = null,
        ?array $data = null,
        ?int $campaignId = null,
    ): self {
        return self::query()->create([
            'user_id' => $user->id,
            'type_notification_id' => $typeNotificationId,
            'notification_campaign_id' => $campaignId,
            'title' => $title,
            'body' => $body,
            'data' => $data,
        ]);
    }
}
