<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class NotificationCampaign extends Model
{
    public const AUDIENCE_ALL_USERS = 'all_users';

    public const AUDIENCE_SELECTED_USERS = 'selected_users';

    public const AUDIENCE_ORGANISATION = 'organisation';

    public const AUDIENCE_PAYS = 'pays';

    public const DEVICE_SCOPE_ALL = 'all';

    public const DEVICE_SCOPE_SELECTED = 'selected';

    public const CHANNEL_PUSH = 'push';

    public const CHANNEL_EMAIL = 'email';

    public const STATUS_SCHEDULED = 'scheduled';

    public const STATUS_QUEUED = 'queued';

    public const STATUS_PROCESSING = 'processing';

    public const STATUS_COMPLETED = 'completed';

    public const STATUS_CANCELLED = 'cancelled';

    public const STATUS_FAILED = 'failed';

    /**
     * @var list<string>
     */
    protected $fillable = [
        'sent_by',
        'type_notification_id',
        'channels',
        'audience_type',
        'organisation_id',
        'pays_id',
        'device_scope',
        'title',
        'body',
        'email_subject',
        'scheduled_at',
        'status',
        'stats',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'channels' => 'array',
            'stats' => 'array',
            'scheduled_at' => 'datetime',
        ];
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sent_by');
    }

    public function typeNotification(): BelongsTo
    {
        return $this->belongsTo(TypeNotification::class);
    }

    public function organisation(): BelongsTo
    {
        return $this->belongsTo(Organisation::class);
    }

    public function pays(): BelongsTo
    {
        return $this->belongsTo(Pays::class);
    }

    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class, 'notification_campaign_user');
    }

    public function devices(): BelongsToMany
    {
        return $this->belongsToMany(Device::class, 'notification_campaign_device');
    }

    /**
     * @return HasMany<NotificationDelivery, $this>
     */
    public function deliveries(): HasMany
    {
        return $this->hasMany(NotificationDelivery::class);
    }

    public function includesChannel(string $channel): bool
    {
        return in_array($channel, $this->channels ?? [], true);
    }

    public function isEditable(): bool
    {
        return in_array($this->status, [self::STATUS_SCHEDULED], true);
    }
}
