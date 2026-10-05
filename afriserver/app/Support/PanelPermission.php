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

    public const PLATFORMS_VIEW = 'platforms.view';

    public const PLATFORMS_CREATE = 'platforms.create';

    public const PLATFORMS_UPDATE = 'platforms.update';

    public const PLATFORMS_DELETE = 'platforms.delete';

    public const SERVICES_VIEW = 'services.view';

    public const SERVICES_CREATE = 'services.create';

    public const SERVICES_UPDATE = 'services.update';

    public const SERVICES_DELETE = 'services.delete';

    public const PLANS_VIEW = 'plans.view';

    public const PLANS_CREATE = 'plans.create';

    public const PLANS_UPDATE = 'plans.update';

    public const PLANS_DELETE = 'plans.delete';

    public const SUBSCRIPTIONS_VIEW = 'subscriptions.view';

    public const SUBSCRIPTIONS_CREATE = 'subscriptions.create';

    public const SUBSCRIPTIONS_UPDATE = 'subscriptions.update';

    public const SUBSCRIPTIONS_DELETE = 'subscriptions.delete';

    public const TYPE_TRANSACTIONS_VIEW = 'type_transactions.view';

    public const TYPE_TRANSACTIONS_CREATE = 'type_transactions.create';

    public const TYPE_TRANSACTIONS_UPDATE = 'type_transactions.update';

    public const TYPE_TRANSACTIONS_DELETE = 'type_transactions.delete';

    public const TRANSACTIONS_VIEW = 'transactions.view';

    public const TRANSACTIONS_CREATE = 'transactions.create';

    public const TRANSACTIONS_UPDATE = 'transactions.update';

    public const TRANSACTIONS_DELETE = 'transactions.delete';

    public const OBSERVABILITY_VIEW = 'observability.view';

    public const OBSERVABILITY_DELETE = 'observability.delete';

    public const TYPE_NOTIFICATIONS_VIEW = 'type_notifications.view';

    public const TYPE_NOTIFICATIONS_CREATE = 'type_notifications.create';

    public const TYPE_NOTIFICATIONS_UPDATE = 'type_notifications.update';

    public const TYPE_NOTIFICATIONS_DELETE = 'type_notifications.delete';

    public const NOTIFICATION_CAMPAIGNS_VIEW = 'notification_campaigns.view';

    public const NOTIFICATION_CAMPAIGNS_CREATE = 'notification_campaigns.create';

    public const NOTIFICATION_CAMPAIGNS_UPDATE = 'notification_campaigns.update';

    public const NOTIFICATION_CAMPAIGNS_DELETE = 'notification_campaigns.delete';

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
            self::PLATFORMS_VIEW,
            self::PLATFORMS_CREATE,
            self::PLATFORMS_UPDATE,
            self::PLATFORMS_DELETE,
            self::SERVICES_VIEW,
            self::SERVICES_CREATE,
            self::SERVICES_UPDATE,
            self::SERVICES_DELETE,
            self::PLANS_VIEW,
            self::PLANS_CREATE,
            self::PLANS_UPDATE,
            self::PLANS_DELETE,
            self::SUBSCRIPTIONS_VIEW,
            self::SUBSCRIPTIONS_CREATE,
            self::SUBSCRIPTIONS_UPDATE,
            self::SUBSCRIPTIONS_DELETE,
            self::TYPE_TRANSACTIONS_VIEW,
            self::TYPE_TRANSACTIONS_CREATE,
            self::TYPE_TRANSACTIONS_UPDATE,
            self::TYPE_TRANSACTIONS_DELETE,
            self::TRANSACTIONS_VIEW,
            self::TRANSACTIONS_CREATE,
            self::TRANSACTIONS_UPDATE,
            self::TRANSACTIONS_DELETE,
            self::OBSERVABILITY_VIEW,
            self::OBSERVABILITY_DELETE,
            self::TYPE_NOTIFICATIONS_VIEW,
            self::TYPE_NOTIFICATIONS_CREATE,
            self::TYPE_NOTIFICATIONS_UPDATE,
            self::TYPE_NOTIFICATIONS_DELETE,
            self::NOTIFICATION_CAMPAIGNS_VIEW,
            self::NOTIFICATION_CAMPAIGNS_CREATE,
            self::NOTIFICATION_CAMPAIGNS_UPDATE,
            self::NOTIFICATION_CAMPAIGNS_DELETE,
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
