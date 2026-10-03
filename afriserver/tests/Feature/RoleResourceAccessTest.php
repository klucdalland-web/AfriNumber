<?php

use App\Filament\Resources\Roles\RoleResource;
use App\Filament\Resources\Users\UserResource;
use App\Models\TypeUser;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
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

    TypeUser::query()->updateOrCreate(
        ['code' => 'user'],
        [
            'label' => 'Utilisateur',
            'description' => 'Utilisateur standard',
            'actif' => true,
        ],
    );

    $this->seed(RolesAndPermissionsSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

test('super_admin can open the roles resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $this->actingAs($admin);

    expect(RoleResource::canViewAny())->toBeTrue();

    $this->get(RoleResource::getUrl('index'))->assertOk();
});

test('operateur cannot open the roles resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $this->actingAs($admin);

    expect(RoleResource::canViewAny())->toBeFalse();

    $this->get(RoleResource::getUrl('index'))->assertForbidden();
});

test('admin without roles cannot open the roles resource', function (): void {
    $admin = User::factory()->admin()->create();

    $this->actingAs($admin);

    expect(RoleResource::canViewAny())->toBeFalse();

    $this->get(RoleResource::getUrl('index'))->assertForbidden();
});

test('super_admin can open the administrators resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $this->actingAs($admin);

    expect(UserResource::canViewAny())->toBeTrue();

    $this->get(UserResource::getUrl('index'))->assertOk();
});

test('non-admin users are still redirected away from the panel', function (): void {
    $user = User::factory()->ofType('user')->create();
    $user->assignRole('super_admin');

    $this->actingAs($user)
        ->get('/afriNetAdmin')
        ->assertRedirect(Filament::getLoginUrl());

    $this->assertGuest();
});
