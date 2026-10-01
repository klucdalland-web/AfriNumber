<?php

use App\Filament\Resources\Continents\ContinentResource;
use App\Filament\Resources\Organisations\OrganisationResource;
use App\Filament\Resources\Pays\PaysResource;
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

test('gestionnaire can open localisation resources', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('gestionnaire');

    $this->actingAs($admin);

    expect(ContinentResource::canViewAny())->toBeTrue()
        ->and(OrganisationResource::canViewAny())->toBeTrue()
        ->and(PaysResource::canViewAny())->toBeTrue();

    $this->get(ContinentResource::getUrl('index'))->assertOk();
    $this->get(OrganisationResource::getUrl('index'))->assertOk();
    $this->get(PaysResource::getUrl('index'))->assertOk();
});

test('operateur cannot open localisation resources', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $this->actingAs($admin);

    expect(ContinentResource::canViewAny())->toBeFalse()
        ->and(OrganisationResource::canViewAny())->toBeFalse()
        ->and(PaysResource::canViewAny())->toBeFalse();

    $this->get(ContinentResource::getUrl('index'))->assertForbidden();
    $this->get(OrganisationResource::getUrl('index'))->assertForbidden();
    $this->get(PaysResource::getUrl('index'))->assertForbidden();
});
