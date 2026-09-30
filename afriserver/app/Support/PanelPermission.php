<?php

namespace App\Support;

final class PanelPermission
{
    public const USERS_VIEW = 'users.view';

    public const USERS_CREATE = 'users.create';

    public const USERS_UPDATE = 'users.update';

    public const USERS_DELETE = 'users.delete';

    public const ORGANISATIONS_VIEW = 'organisations.view';

    public const ORGANISATIONS_CREATE = 'organisations.create';

    public const ORGANISATIONS_UPDATE = 'organisations.update';

    public const ORGANISATIONS_DELETE = 'organisations.delete';

    public const PAYS_VIEW = 'pays.view';

    public const PAYS_CREATE = 'pays.create';

    public const PAYS_UPDATE = 'pays.update';

    public const PAYS_DELETE = 'pays.delete';

    public const PROFILES_VIEW = 'profiles.view';

    public const PROFILES_CREATE = 'profiles.create';

    public const PROFILES_UPDATE = 'profiles.update';

    public const PROFILES_DELETE = 'profiles.delete';

    public const ROLES_VIEW = 'roles.view';

    public const ROLES_CREATE = 'roles.create';

    public const ROLES_UPDATE = 'roles.update';

    public const ROLES_DELETE = 'roles.delete';

    public const CONTINENTS_VIEW = 'continents.view';

    public const CONTINENTS_CREATE = 'continents.create';

    public const CONTINENTS_UPDATE = 'continents.update';

    public const CONTINENTS_DELETE = 'continents.delete';

    

    /**
     * @return list<string>
     */
    public static function all(): array
    {
        return [
            self::USERS_VIEW,
            self::USERS_CREATE,
            self::USERS_UPDATE,
            self::USERS_DELETE,
            self::ORGANISATIONS_VIEW,
            self::ORGANISATIONS_CREATE,
            self::ORGANISATIONS_UPDATE,
            self::ORGANISATIONS_DELETE,
            self::PAYS_VIEW,
            self::PAYS_CREATE,
            self::PAYS_UPDATE,
            self::PAYS_DELETE,
            self::PROFILES_VIEW,
            self::PROFILES_CREATE,
            self::PROFILES_UPDATE,
            self::PROFILES_DELETE,
            self::ROLES_VIEW,
            self::ROLES_CREATE,
            self::ROLES_UPDATE,
            self::ROLES_DELETE,
            self::CONTINENTS_VIEW,
            self::CONTINENTS_CREATE,
            self::CONTINENTS_UPDATE,
            self::CONTINENTS_DELETE,
        ];
    }

    /**
     * @return list<string>
     */
    public static function forResource(string $prefix): array
    {
        return [
            "{$prefix}.view",
            "{$prefix}.create",
            "{$prefix}.update",
            "{$prefix}.delete",
        ];
    }
}
