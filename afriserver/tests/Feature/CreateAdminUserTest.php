<?php

use App\Filament\Resources\Users\Pages\ManageUsers;
use App\Filament\Resources\Users\UserResource;
use App\Models\TypeUser;
use App\Models\User;
use Database\Seeders\RolesAndPermissionsSeeder;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Livewire\Livewire;
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

    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);
});

test('super_admin can create an administrator and credentials email is sent', function (): void {
    $creator = User::factory()->admin()->create();
    $creator->assignRole('super_admin');

    $operateurRoleId = Role::query()->where('name', 'operateur')->value('id');

    $this->actingAs($creator);

    expect(UserResource::canCreate())->toBeTrue();

    Livewire::test(ManageUsers::class)
        ->callAction('create', data: [
            'name' => 'Doe',
            'first_name' => 'Jane',
            'email' => 'jane.admin@example.com',
            'phone_number' => '+22991112233',
            'roles' => [$operateurRoleId],
        ])
        ->assertHasNoActionErrors();

    $created = User::query()->where('email', 'jane.admin@example.com')->first();

    expect($created)->not->toBeNull()
        ->and($created->isAdminType())->toBeTrue()
        ->and($created->status_valide)->toBe('valide')
        ->and($created->hasRole('operateur'))->toBeTrue()
        ->and(Hash::check('password', $created->password))->toBeFalse();

    Http::assertSent(fn ($request): bool => $request['to'] === 'jane.admin@example.com'
        && $request['subject'] === 'Vos accès administrateur AfriNumber');
});

test('operateur cannot create an administrator', function (): void {
    $admin = User::factory()->admin()->create();
    $admin->assignRole('operateur');

    $this->actingAs($admin);

    expect(UserResource::canCreate())->toBeFalse();
});
