<?php

use App\Filament\Pages\Auth\RequestPasswordReset;
use App\Filament\Pages\Auth\ResetPassword;
use App\Models\PasswordResetCode;
use App\Models\TypeUser;
use App\Models\User;
use App\Services\AdminPasswordResetService;
use Filament\Facades\Filament;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\URL;
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

    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);
});

test('la page de demande de reset est accessible depuis le dashboard', function (): void {
    $this->get(Filament::getRequestPasswordResetUrl())
        ->assertOk();
});

test('un admin peut demander un code OTP de réinitialisation', function (): void {
    $admin = User::factory()->admin()->create([
        'email' => 'admin-reset@example.com',
    ]);

    Livewire::test(RequestPasswordReset::class)
        ->fillForm([
            'email' => $admin->email,
        ])
        ->call('request')
        ->assertHasNoFormErrors()
        ->assertRedirect();

    expect(PasswordResetCode::query()->where('email', $admin->email)->exists())->toBeTrue();

    Http::assertSent(fn ($request): bool => $request['to'] === $admin->email
        && str_contains((string) $request['html'], 'code'));
});

test('un compte non-admin ne reçoit pas de code mais voit le même message', function (): void {
    $user = User::factory()->ofType('user')->create([
        'email' => 'user-reset@example.com',
    ]);

    Livewire::test(RequestPasswordReset::class)
        ->fillForm([
            'email' => $user->email,
        ])
        ->call('request')
        ->assertHasNoFormErrors()
        ->assertRedirect();

    expect(PasswordResetCode::query()->where('email', $user->email)->exists())->toBeFalse();
});

test('un admin peut réinitialiser son mot de passe avec le code OTP', function (): void {
    $admin = User::factory()->admin()->create([
        'email' => 'admin-otp@example.com',
        'password' => 'OldPassword#123',
    ]);

    $plainCode = '654321';

    PasswordResetCode::query()->create([
        'email' => $admin->email,
        'phone_number' => $admin->phone_number,
        'code' => Hash::make($plainCode),
        'attempts' => 0,
        'resend_count' => 0,
        'locked_until' => null,
        'expires_at' => now()->addMinutes(15),
    ]);

    $url = URL::temporarySignedRoute(
        'filament.afriNetAdmin.auth.password-reset.reset',
        now()->addMinutes(30),
        [
            'email' => $admin->email,
            'token' => 'otp',
        ],
    );

    $this->get($url)->assertOk();

    Livewire::withQueryParams([
        'email' => $admin->email,
        'token' => 'otp',
    ])
        ->test(ResetPassword::class, [
            'email' => $admin->email,
            'token' => 'otp',
        ])
        ->fillForm([
            'email' => $admin->email,
            'code' => $plainCode,
            'password' => 'NewPassword#456',
            'passwordConfirmation' => 'NewPassword#456',
        ])
        ->call('resetPassword')
        ->assertHasNoFormErrors()
        ->assertRedirect(Filament::getLoginUrl());

    $admin->refresh();

    expect(Hash::check('NewPassword#456', $admin->password))->toBeTrue()
        ->and(PasswordResetCode::query()->where('email', $admin->email)->exists())->toBeFalse();
});

test('un code OTP incorrect est refusé', function (): void {
    $admin = User::factory()->admin()->create([
        'email' => 'admin-bad-otp@example.com',
        'password' => 'KeepThisPassword#1',
    ]);

    PasswordResetCode::query()->create([
        'email' => $admin->email,
        'phone_number' => $admin->phone_number,
        'code' => Hash::make('111111'),
        'attempts' => 0,
        'resend_count' => 0,
        'locked_until' => null,
        'expires_at' => now()->addMinutes(15),
    ]);

    Livewire::test(ResetPassword::class, [
        'email' => $admin->email,
    ])
        ->fillForm([
            'email' => $admin->email,
            'code' => '000000',
            'password' => 'NewPassword#456',
            'passwordConfirmation' => 'NewPassword#456',
        ])
        ->call('resetPassword')
        ->assertHasFormErrors(['code']);

    expect(Hash::check('KeepThisPassword#1', $admin->fresh()->password))->toBeTrue();
});

test('si l\'envoi mail échoue, le reset admin affiche une erreur et n\'enregistre pas de code', function (): void {
    // Http::fake(array) fusionne les stubs : il faut remplacer la Factory
    // pour écraser le stub 200 du beforeEach.
    Http::swap(new Factory);
    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['error' => 'send_failed'], 500),
    ]);

    $admin = User::factory()->admin()->create([
        'email' => 'admin-mail-fail@example.com',
    ]);

    Livewire::test(RequestPasswordReset::class)
        ->fillForm([
            'email' => $admin->email,
        ])
        ->call('request')
        ->assertHasErrors(['data.email'])
        ->assertNoRedirect();

    expect(PasswordResetCode::query()->where('email', $admin->email)->exists())->toBeFalse();
});

test('le service admin envoie un OTP uniquement aux administrateurs', function (): void {
    $admin = User::factory()->admin()->create([
        'email' => 'svc-admin@example.com',
    ]);
    $user = User::factory()->ofType('user')->create([
        'email' => 'svc-user@example.com',
    ]);

    $service = app(AdminPasswordResetService::class);

    $adminResult = $service->request($admin->email);
    $userResult = $service->request($user->email);

    expect($adminResult['sent'])->toBeTrue()
        ->and($userResult['sent'])->toBeFalse()
        ->and($adminResult['message'])->toBe($userResult['message'])
        ->and(PasswordResetCode::query()->where('email', $admin->email)->exists())->toBeTrue()
        ->and(PasswordResetCode::query()->where('email', $user->email)->exists())->toBeFalse();
});
