<?php

use App\Filament\Pages\Auth\Login;
use App\Models\TypeUser;
use App\Models\User;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Livewire\Livewire;

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
});

test('an admin user can access the afriNetAdmin panel', function (): void {
    $admin = User::factory()->admin()->create();

    expect($admin->canAccessPanel(Filament::getPanel('afriNetAdmin')))->toBeTrue();

    $this->actingAs($admin)
        ->get('/afriNetAdmin')
        ->assertOk();
});

test('a non-admin user is redirected to login with a clear message', function (): void {
    $user = User::factory()->ofType('user')->create();

    expect($user->canAccessPanel(Filament::getPanel('afriNetAdmin')))->toBeFalse();

    $response = $this->actingAs($user)
        ->get('/afriNetAdmin');

    $response->assertRedirect(Filament::getLoginUrl());
    $this->assertGuest();

    $notifications = session('filament.notifications');
    expect($notifications)->not->toBeEmpty()
        ->and($notifications[0]['title'] ?? null)->toBe('Accès non autorisé')
        ->and($notifications[0]['body'] ?? null)->toContain('pas autorisé');
});

test('a user without type is redirected to login', function (): void {
    $user = User::factory()->create(['type_user_id' => null]);

    $this->actingAs($user)
        ->get('/afriNetAdmin')
        ->assertRedirect(Filament::getLoginUrl());

    $this->assertGuest();
});

test('login with a non-admin account shows an unauthorized message', function (): void {
    $user = User::factory()->ofType('user')->create([
        'email' => 'user@example.com',
        'password' => 'password',
    ]);

    Livewire::test(Login::class)
        ->fillForm([
            'email' => $user->email,
            'password' => 'password',
        ])
        ->call('authenticate')
        ->assertHasFormErrors(['email']);
});
