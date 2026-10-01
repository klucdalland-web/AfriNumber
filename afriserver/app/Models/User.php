<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Database\Factories\UserFactory;
use Filament\Models\Contracts\FilamentUser;
use Filament\Panel;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\Hidden;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\HasOneThrough;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

#[Fillable(['name', 'email', 'password', 'phone_number', 'statut', 'status_valide', 'pays_id', 'type_user_id', 'first_name', 'failed_login_attempts',
    'locked_until', ])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable implements FilamentUser
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, HasFactory, HasRoles, Notifiable;

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'locked_until' => 'datetime',

        ];
    }

    /**
     * @var array<string, mixed>
     */
    protected $attributes = [
        'statut' => 'actif',
        'status_valide' => 'non_valide',
    ];

    public function pays(): BelongsTo
    {
        return $this->belongsTo(Pays::class);
    }

    /** Organisation dérivée via le pays. */
    public function organisation(): HasOneThrough
    {
        return $this->hasOneThrough(
            Organisation::class,
            Pays::class,
            'id',
            'id',
            'pays_id',
            'organisation_id'
        );
    }

    public function typeUser(): BelongsTo
    {
        return $this->belongsTo(TypeUser::class);
    }

    public function profile(): HasOne
    {
        return $this->hasOne(Profile::class);
    }

    public function canAccessPanel(Panel $panel): bool
    {
        if ($panel->getId() !== 'afriNetAdmin') {
            return false;
        }

        return $this->isAdminType();
    }

    public function isAdminType(): bool
    {
        return $this->typeUser?->code === 'admin';
    }
}
