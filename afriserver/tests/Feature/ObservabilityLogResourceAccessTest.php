<?php

use App\Filament\Resources\ObservabilityLogs\ObservabilityLogResource;
use App\Models\ObservabilityLog;
use App\Models\TypeUser;
use App\Models\User;
use App\Support\PanelPermission;
use Database\Seeders\RolesAndPermissionsSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Spatie\Permission\Models\Role;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Filament::setCurrentPanel(Filament::getPanel('afriNetAdmin'));

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

test('super_admin can open the observability resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    ObservabilityLog::query()->create([
        'category' => 'security',
        'action' => 'auth.login_failed',
        'level' => 'warning',
        'message' => 'Tentative échouée',
        'created_at' => now(),
    ]);

    $this->actingAs($admin);

    expect(ObservabilityLogResource::canViewAny())->toBeTrue()
        ->and(ObservabilityLogResource::canCreate())->toBeFalse();

    $this->get(ObservabilityLogResource::getUrl('index'))->assertOk();
});

test('operateur cannot open the observability resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $this->actingAs($admin);

    expect(ObservabilityLogResource::canViewAny())->toBeFalse();

    $this->get(ObservabilityLogResource::getUrl('index'))->assertForbidden();
});

test('gestionnaire cannot open the observability resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('gestionnaire');

    $this->actingAs($admin);

    expect(ObservabilityLogResource::canViewAny())->toBeFalse();

    $this->get(ObservabilityLogResource::getUrl('index'))->assertForbidden();
});

test('admin with observability.view can read but not mutate logs', function (): void {
    $admin = User::factory()->admin()->create();
    $role = Role::query()->create([
        'name' => 'audit',
        'guard_name' => 'web',
    ]);
    $role->givePermissionTo([PanelPermission::OBSERVABILITY_VIEW]);
    $admin->assignRole($role);

    $log = ObservabilityLog::query()->create([
        'category' => 'security',
        'action' => 'auth.login_failed',
        'level' => 'warning',
        'message' => 'Tentative échouée',
        'created_at' => now(),
    ]);

    expect($admin->can('viewAny', ObservabilityLog::class))->toBeTrue()
        ->and($admin->can('view', $log))->toBeTrue()
        ->and($admin->can('create', ObservabilityLog::class))->toBeFalse()
        ->and($admin->can('update', $log))->toBeFalse()
        ->and($admin->can('delete', $log))->toBeFalse();
});
