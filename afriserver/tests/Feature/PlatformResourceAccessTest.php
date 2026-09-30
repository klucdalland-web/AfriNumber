<?php

use App\Filament\Resources\Platforms\PlatformResource;
use App\Models\Platform;
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

    $this->seed(RolesAndPermissionsSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

test('super_admin can open the platforms resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $this->actingAs($admin);

    expect(PlatformResource::canViewAny())->toBeTrue();

    $this->get(PlatformResource::getUrl('index'))->assertOk();
});

test('gestionnaire can manage platforms', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('gestionnaire');

    Platform::query()->create([
        'label' => 'Android',
        'description' => 'App Android',
        'actif' => true,
    ]);

    $this->actingAs($admin);

    expect(PlatformResource::canViewAny())->toBeTrue()
        ->and(PlatformResource::canCreate())->toBeTrue();

    $this->get(PlatformResource::getUrl('index'))->assertOk();
});

test('operateur cannot open the platforms resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $this->actingAs($admin);

    expect(PlatformResource::canViewAny())->toBeFalse();

    $this->get(PlatformResource::getUrl('index'))->assertForbidden();
});
