<?php

namespace App\Filament\Concerns;

use Illuminate\Database\Eloquent\Model;

/**
 * Convention for Filament Resources: declare a permission prefix
 * (e.g. "users") matching PanelPermission names "{prefix}.view|create|update|delete".
 *
 * Prefer registering a Policy that uses ChecksPermissions; this trait is a
 * fallback when overriding Resource authorization without a policy.
 */
trait HasResourcePermissions
{
    abstract public static function getPermissionPrefix(): string;

    public static function canViewAny(): bool
    {
        return static::userCan(static::getPermissionPrefix().'.view');
    }

    public static function canCreate(): bool
    {
        return static::userCan(static::getPermissionPrefix().'.create');
    }

    public static function canEdit(Model $record): bool
    {
        return static::userCan(static::getPermissionPrefix().'.update');
    }

    public static function canDelete(Model $record): bool
    {
        return static::userCan(static::getPermissionPrefix().'.delete');
    }

    public static function canDeleteAny(): bool
    {
        return static::userCan(static::getPermissionPrefix().'.delete');
    }

    public static function canView(Model $record): bool
    {
        return static::userCan(static::getPermissionPrefix().'.view');
    }

    protected static function userCan(string $permission): bool
    {
        $user = auth()->user();

        return $user !== null && $user->can($permission);
    }
}
