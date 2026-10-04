<?php

namespace Database\Seeders;

use App\Support\PanelPermission;
use Illuminate\Database\Seeder;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

class RolesAndPermissionsSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        app()[PermissionRegistrar::class]->forgetCachedPermissions();

        foreach (PanelPermission::all() as $permission) {
            Permission::query()->firstOrCreate([
                'name' => $permission,
                'guard_name' => 'web',
            ]);
        }

        $superAdmin = Role::query()->firstOrCreate([
            'name' => 'super_admin',
            'guard_name' => 'web',
        ]);
        $superAdmin->syncPermissions(PanelPermission::all());

        $operateur = Role::query()->firstOrCreate([
            'name' => 'operateur',
            'guard_name' => 'web',
        ]);
        $operateur->syncPermissions([
            PanelPermission::USERS_VIEW,
            PanelPermission::PROFILES_VIEW,
            PanelPermission::PROFILES_CREATE,
            PanelPermission::PROFILES_UPDATE,
            PanelPermission::PROFILES_DELETE,
        ]);

        $gestionnaire = Role::query()->firstOrCreate([
            'name' => 'gestionnaire',
            'guard_name' => 'web',
        ]);
        $gestionnaire->syncPermissions([
            ...PanelPermission::forResource('pays'),
            ...PanelPermission::forResource('organisations'),
            ...PanelPermission::forResource('continents'),
            ...PanelPermission::forResource('platforms'),
            ...PanelPermission::forResource('services'),
            ...PanelPermission::forResource('plans'),
            ...PanelPermission::forResource('subscriptions'),
            ...PanelPermission::forResource('type_transactions'),
            ...PanelPermission::forResource('transactions'),
        ]);
    }
}
