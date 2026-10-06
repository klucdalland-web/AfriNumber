<?php

use App\Filament\Resources\Clients\ClientResource;
use App\Filament\Resources\Clients\Pages\ListClients;
use App\Filament\Resources\Clients\Pages\ViewClient;
use App\Models\Profile;
use App\Models\TypeUser;
use App\Models\User;
use App\Services\KycAdminService;
use Database\Seeders\RolesAndPermissionsSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use InvalidArgumentException;
use Livewire\Livewire;
use Spatie\Permission\PermissionRegistrar;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Filament::setCurrentPanel(Filament::getPanel('afriNetAdmin'));

    TypeUser::query()->updateOrCreate(
        ['code' => 'admin'],
        ['label' => 'Administrateur', 'description' => 'Administrateur système', 'actif' => true],
    );
    TypeUser::query()->updateOrCreate(
        ['code' => 'user'],
        ['label' => 'Utilisateur', 'description' => 'Client mobile', 'actif' => true],
    );

    $this->seed(RolesAndPermissionsSeeder::class);
    app()[PermissionRegistrar::class]->forgetCachedPermissions();
});

test('operateur can open clients list and view a client', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $client = User::factory()->ofType('user')->create([
        'name' => 'Doe',
        'first_name' => 'Jane',
        'email' => 'jane.doe@example.com',
    ]);

    Profile::query()->create([
        'user_id' => $client->id,
        'status' => Profile::STATUS_VALIDATION_MANUELLE,
        'rejection_reason' => 'Selfie ambigu',
    ]);

    $this->actingAs($admin);

    expect(ClientResource::canViewAny())->toBeTrue();

    $this->get(ClientResource::getUrl('index'))->assertOk();
    $this->get(ClientResource::getUrl('view', ['record' => $client]))->assertOk();

    Livewire::test(ListClients::class)->assertSuccessful();
    Livewire::test(ViewClient::class, ['record' => $client->getRouteKey()])
        ->assertSuccessful()
        ->assertSee('jane.doe@example.com')
        ->assertSee('Validation manuelle');
});

test('gestionnaire cannot open clients resource', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('gestionnaire');

    $this->actingAs($admin);

    expect(ClientResource::canViewAny())->toBeFalse();
    $this->get(ClientResource::getUrl('index'))->assertForbidden();
});

test('clients list only shows mobile users not admins', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('super_admin');

    $client = User::factory()->ofType('user')->create(['email' => 'client@example.com']);
    User::factory()->admin()->create(['email' => 'other-admin@example.com']);

    $this->actingAs($admin);

    Livewire::test(ListClients::class)
        ->assertSuccessful()
        ->assertCanSeeTableRecords([$client])
        ->assertDontSee('other-admin@example.com');
});

test('approve kyc action only works for validation_manuelle', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $client = User::factory()->ofType('user')->create(['status_valide' => 'non_valide']);
    Profile::query()->create([
        'user_id' => $client->id,
        'status' => Profile::STATUS_VALIDATION_MANUELLE,
        'documents' => [
            ['champ' => 'photopath', 'path' => $client->id.'/selfie.jpg'],
        ],
    ]);

    $this->actingAs($admin);

    Livewire::test(ViewClient::class, ['record' => $client->getRouteKey()])
        ->callAction('approveKyc')
        ->assertHasNoActionErrors();

    expect($client->fresh()->status_valide)->toBe('valide')
        ->and($client->fresh()->profile->status)->toBe(Profile::STATUS_APPROUVE);
});

test('approve kyc action is hidden when not in manual review', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $client = User::factory()->ofType('user')->create();
    Profile::query()->create([
        'user_id' => $client->id,
        'status' => Profile::STATUS_EN_COURS_DE_VERIFICATION,
    ]);

    $this->actingAs($admin);

    Livewire::test(ViewClient::class, ['record' => $client->getRouteKey()])
        ->assertActionHidden('approveKyc')
        ->assertActionHidden('rejectKyc');
});

test('kyc admin service rejects non manual profiles', function (): void {
    $client = User::factory()->ofType('user')->create();
    Profile::query()->create([
        'user_id' => $client->id,
        'status' => Profile::STATUS_EN_COURS_DE_VERIFICATION,
    ]);

    expect(fn () => app(KycAdminService::class)->approve($client))
        ->toThrow(InvalidArgumentException::class);
});

test('kyc admin service can reject a manual review profile', function (): void {
    $client = User::factory()->ofType('user')->create(['status_valide' => 'non_valide']);
    Profile::query()->create([
        'user_id' => $client->id,
        'status' => Profile::STATUS_VALIDATION_MANUELLE,
    ]);

    $profile = app(KycAdminService::class)->reject($client, 'Pièce illisible');

    expect($profile->status)->toBe(Profile::STATUS_REJETE)
        ->and($profile->rejection_reason)->toBe('Pièce illisible')
        ->and($client->fresh()->status_valide)->toBe('non_valide');
});
