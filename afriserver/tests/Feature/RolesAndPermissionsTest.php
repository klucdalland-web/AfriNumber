<?php

use App\Models\TypeUser;
use App\Models\User;
use App\Support\PanelPermission;
use Database\Seeders\RolesAndPermissionsSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Permission;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    TypeUser::query()->updateOrCreate(
        ['code' => 'admin'],
        [
            'label' => 'Administrateur',
            'description' => 'Administrateur système',
            'actif' => true,
        ],
    );

    $this->seed(RolesAndPermissionsSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

test('roles and permissions seeder creates expected roles', function (): void {
    expect(Role::query()->where('name', 'super_admin')->exists())->toBeTrue()
        ->and(Role::query()->where('name', 'operateur')->exists())->toBeTrue()
        ->and(Role::query()->where('name', 'gestionnaire')->exists())->toBeTrue()
        ->and(Permission::query()->count())->toBe(count(PanelPermission::all()));
});

test('super_admin can perform any panel permission', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    expect($admin->can(PanelPermission::ROLES_VIEW))->toBeTrue()
        ->and($admin->can(PanelPermission::USERS_DELETE))->toBeTrue()
        ->and($admin->can(PanelPermission::PAYS_CREATE))->toBeTrue();
});

test('operateur can view users and manage profiles but not roles', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    expect($admin->can(PanelPermission::USERS_VIEW))->toBeTrue()
        ->and($admin->can(PanelPermission::PROFILES_UPDATE))->toBeTrue()
        ->and($admin->can(PanelPermission::ROLES_VIEW))->toBeFalse()
        ->and($admin->can(PanelPermission::PAYS_VIEW))->toBeFalse();
});

test('gestionnaire can manage pays and organisations but not profiles', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('gestionnaire');

    expect($admin->can(PanelPermission::PAYS_UPDATE))->toBeTrue()
        ->and($admin->can(PanelPermission::ORGANISATIONS_VIEW))->toBeTrue()
        ->and($admin->can(PanelPermission::CONTINENTS_CREATE))->toBeTrue()
        ->and($admin->can(PanelPermission::PLATFORMS_UPDATE))->toBeTrue()
        ->and($admin->can(PanelPermission::SERVICES_VIEW))->toBeTrue()
        ->and($admin->can(PanelPermission::PLANS_UPDATE))->toBeTrue()
        ->and($admin->can(PanelPermission::SUBSCRIPTIONS_CREATE))->toBeTrue()
        ->and($admin->can(PanelPermission::OBSERVABILITY_VIEW))->toBeFalse()
        ->and($admin->can(PanelPermission::PROFILES_VIEW))->toBeFalse()
        ->and($admin->can(PanelPermission::ROLES_VIEW))->toBeFalse();
});

test('admin without spatie role cannot manage panel resources', function (): void {
    $admin = User::factory()->admin()->create();

    expect($admin->canAccessPanel(Filament\Facades\Filament::getPanel('afriNetAdmin')))->toBeTrue()
        ->and($admin->can(PanelPermission::ROLES_VIEW))->toBeFalse()
        ->and($admin->can(PanelPermission::USERS_VIEW))->toBeFalse();
});

test('super_admin role cannot be deleted via policy', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $role = Role::query()->where('name', 'super_admin')->firstOrFail();

    expect($admin->can('delete', $role))->toBeFalse();
});
