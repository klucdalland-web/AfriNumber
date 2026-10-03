<?php

use App\Models\PasswordResetCode;
use App\Models\TypeUser;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);

    $this->withHeader('x-api-key', (string) env('X_API_KEY_V1', 'testing-api-key'));

    TypeUser::query()->updateOrCreate(
        ['code' => 'user'],
        [
            'label' => 'Utilisateur',
            'description' => 'Utilisateur standard',
            'actif' => true,
        ],
    );

    TypeUser::query()->updateOrCreate(
        ['code' => 'admin'],
        [
            'label' => 'Administrateur',
            'description' => 'Administrateur système',
            'actif' => true,
        ],
    );
});

/**
 * @return array<string, mixed>
 */
function apiLoginDevicePayload(string $email, string $password): array
{
    return [
        'email' => $email,
        'password' => $password,
        'device_name' => 'test-device',
        'platform' => 'android',
        'device_id' => 'device-test-001',
        'device_model' => 'Pixel',
        'os_version' => '14',
        'app_version' => '1.0.0',
        'fcm_token' => 'fcm-test-token',
    ];
}

test('a user can register via the v1 api', function (): void {
    $response = $this->postJson('/api/v1/auth/register', [
        'name' => 'Jean Dupont',
        'email' => 'jean@example.com',
        'phone_number' => '+22990000001',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'device_name' => 'iphone',
    ]);

    $response->assertCreated()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.email', 'jean@example.com')
        ->assertJsonPath('data.token_type', 'Bearer')
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'user' => ['id', 'name', 'email', 'phone_number'],
                'token',
                'token_type',
            ],
        ]);

    $this->assertDatabaseHas('users', [
        'email' => 'jean@example.com',
        'phone_number' => '+22990000001',
    ]);
});

test('registration requires unique email and phone number', function (): void {
    User::factory()->create([
        'email' => 'taken@example.com',
        'phone_number' => '+22990000002',
    ]);

    $response = $this->postJson('/api/v1/auth/register', [
        'name' => 'Autre',
        'email' => 'taken@example.com',
        'phone_number' => '+22990000002',
        'password' => 'password123',
        'password_confirmation' => 'password123',
    ]);

    $response->assertUnprocessable()
        ->assertJsonValidationErrors(['email', 'phone_number']);
});

test('a user can login with email', function (): void {
    $user = User::factory()->create([
        'email' => 'login@example.com',
        'phone_number' => '+22990000003',
        'password' => Hash::make('password123'),
        'statut' => 'actif',
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'login' => 'login@example.com',
        'password' => 'password123',
        'device_name' => 'android',
    ]);

    $response->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.id', $user->id)
        ->assertJsonStructure([
            'data' => ['user', 'token', 'token_type'],
        ]);
});

test('a user can login with phone number', function (): void {
    User::factory()->create([
        'email' => 'phone@example.com',
        'phone_number' => '+22990000004',
        'password' => Hash::make('password123'),
        'statut' => 'actif',
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'login' => '+22990000004',
        'password' => 'password123',
    ]);

    $response->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.phone_number', '+22990000004');
});

test('login fails with invalid credentials', function (): void {
    User::factory()->create([
        'email' => 'wrong@example.com',
        'phone_number' => '+22990000005',
        'password' => Hash::make('password123'),
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'login' => 'wrong@example.com',
        'password' => 'bad-password',
    ]);

    $response->assertUnprocessable()
        ->assertJsonValidationErrors(['login']);
});

test('inactive users cannot login', function (): void {
    User::factory()->create([
        'email' => 'inactive@example.com',
        'phone_number' => '+22990000006',
        'password' => Hash::make('password123'),
        'statut' => 'inactif',
    ]);

    $response = $this->postJson('/api/v1/auth/login', [
        'login' => 'inactive@example.com',
        'password' => 'password123',
    ]);

    $response->assertForbidden()
        ->assertJsonPath('success', false);
});

test('authenticated user can fetch me and logout', function (): void {
    $user = User::factory()->create([
        'phone_number' => '+22990000007',
        'statut' => 'actif',
    ]);

    $token = $user->createToken('test')->plainTextToken;

    $this->withToken($token)
        ->getJson('/api/v1/auth/me')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.id', $user->id);

    $this->withToken($token)
        ->getJson('/api/v1/user')
        ->assertOk()
        ->assertJsonPath('data.user.email', $user->email);

    $this->withToken($token)
        ->postJson('/api/v1/auth/logout')
        ->assertOk()
        ->assertJsonPath('success', true);

    $this->assertDatabaseCount('personal_access_tokens', 0);

    $this->app['auth']->forgetGuards();

    $this->withToken($token)
        ->getJson('/api/v1/auth/me')
        ->assertUnauthorized();
});

test('authenticated user can change password', function (): void {
    $user = User::factory()->create([
        'phone_number' => '+22990000008',
        'password' => 'password123',
        'statut' => 'actif',
    ]);

    $token = $user->createToken('current')->plainTextToken;
    $user->createToken('other-device');

    $this->withToken($token)
        ->putJson('/api/v1/auth/password', [
            'current_password' => 'password123',
            'password' => 'new-password123',
            'password_confirmation' => 'new-password123',
        ])
        ->assertOk()
        ->assertJsonPath('success', true);

    $user->refresh();

    expect(Hash::check('new-password123', $user->password))->toBeTrue()
        ->and(Hash::check('password123', $user->password))->toBeFalse();

    $this->assertDatabaseCount('personal_access_tokens', 1);

    $this->app['auth']->forgetGuards();

    $this->postJson('/api/v1/auth/login', [
        'login' => $user->email,
        'password' => 'new-password123',
    ])->assertOk();
});

test('change password rejects invalid current password', function (): void {
    $user = User::factory()->create([
        'phone_number' => '+22990000009',
        'password' => 'password123',
        'statut' => 'actif',
    ]);

    $token = $user->createToken('test')->plainTextToken;

    $this->withToken($token)
        ->putJson('/api/v1/auth/password', [
            'current_password' => 'wrong-password',
            'password' => 'new-password123',
            'password_confirmation' => 'new-password123',
        ])
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['current_password']);
});

test('admin cannot login via the api and gets the same response as unknown credentials', function (): void {
    $admin = User::factory()->admin()->create([
        'email' => 'admin-api@example.com',
        'phone_number' => '+22990000010',
        'password' => Hash::make('password123'),
        'statut' => 'actif',
    ]);

    $unknownResponse = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload('unknown@example.com', 'password123')
    );

    $adminResponse = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload($admin->email, 'password123')
    );

    $unknownResponse->assertUnprocessable()
        ->assertJsonValidationErrors(['login']);

    $adminResponse->assertUnprocessable()
        ->assertJsonValidationErrors(['login'])
        ->assertJsonPath('errors.login.0', $unknownResponse->json('errors.login.0'));

    $this->assertDatabaseMissing('otp_verifications', [
        'email' => $admin->email,
        'purpose' => 'login',
    ]);
});

test('forgot password returns the same success for unknown and admin accounts', function (): void {
    $admin = User::factory()->admin()->create([
        'email' => 'admin-reset@example.com',
        'phone_number' => '+22990000011',
        'statut' => 'actif',
    ]);

    $unknownResponse = $this->postJson('/api/v1/auth/forgot-password', [
        'email' => 'nobody@example.com',
    ]);

    $adminResponse = $this->postJson('/api/v1/auth/forgot-password', [
        'email' => $admin->email,
    ]);

    $unknownResponse->assertOk()->assertJsonPath('success', true);
    $adminResponse->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('message', $unknownResponse->json('message'));

    expect(PasswordResetCode::query()->where('email', $admin->email)->exists())->toBeFalse();
});
