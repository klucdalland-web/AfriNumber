<?php

use App\Models\Continent;
use App\Models\Device;
use App\Models\Organisation;
use App\Models\OtpVerification;
use App\Models\PasswordResetCode;
use App\Models\Pays;
use App\Models\Plan;
use App\Models\Platform;
use App\Models\SessionUser;
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

    Platform::query()->firstOrCreate(
        ['label' => 'Android'],
        ['description' => 'Android', 'actif' => true],
    );

    Platform::query()->firstOrCreate(
        ['label' => 'iOS'],
        ['description' => 'iOS', 'actif' => true],
    );

    $organisation = Organisation::query()->create([
        'label' => 'AfriNumber Test',
        'description' => 'Org test',
        'actif' => true,
    ]);

    $continent = Continent::factory()->create();

    $this->pays = Pays::query()->create([
        'continent_id' => $continent->id,
        'organisation_id' => $organisation->id,
        'label' => 'Côte d\'Ivoire',
        'code' => 'CI',
        'indicatif' => '+225',
        'actif' => true,
    ]);

    Plan::query()->firstOrCreate(
        ['code' => Plan::CODE_FREE],
        [
            'label' => 'Free',
            'description' => 'Essai gratuit',
            'price' => 0,
            'currency' => 'XOF',
            'duration_days' => 14,
            'max_numbers' => 1,
            'is_active' => true,
            'sort_order' => 0,
        ],
    );
});

/**
 * @return array<string, mixed>
 */
function apiRegisterPayload(array $overrides = []): array
{
    return array_merge([
        'contrie_id' => test()->pays->id,
        'name' => 'Dupont',
        'first_name' => 'Jean',
        'email' => 'jean@example.com',
        'phone_number' => '0700000001',
        'password' => 'password123',
        'password_confirmation' => 'password123',
        'platform' => 'android',
        'device_id' => 'device-auth-001',
        'device_name' => 'Pixel',
        'device_model' => 'Pixel 8',
        'os_version' => '14',
        'app_version' => '1.0.0',
        'fcm_token' => 'fcm-auth-token',
    ], $overrides);
}

/**
 * @return array<string, mixed>
 */
function apiLoginDevicePayload(string $email, string $password, string $deviceId = 'device-test-001'): array
{
    return [
        'email' => $email,
        'password' => $password,
        'device_name' => 'test-device',
        'platform' => 'android',
        'device_id' => $deviceId,
        'device_model' => 'Pixel',
        'os_version' => '14',
        'app_version' => '1.0.0',
        'fcm_token' => 'fcm-test-token',
    ];
}

/**
 * @return array{0: User, 1: string}
 */
function authUserWithAccessToken(array $userAttributes = []): array
{
    $user = User::factory()->create(array_merge([
        'phone_number' => '+2250700000099',
        'statut' => 'actif',
        'password' => Hash::make('password123'),
    ], $userAttributes));

    $platform = Platform::query()->whereRaw('LOWER(label) = ?', ['android'])->firstOrFail();

    $device = Device::query()->create([
        'user_id' => $user->id,
        'platform_id' => $platform->id,
        'identifier' => 'device-auth-session',
        'name' => 'Test phone',
        'model' => 'Pixel',
        'os_version' => '14',
        'actif' => true,
        'last_used_at' => now(),
    ]);

    SessionUser::query()->create([
        'user_id' => $user->id,
        'device_id' => $device->id,
        'is_active' => true,
    ]);

    $token = $user->createToken('test-access', ['access-api'])->plainTextToken;

    test()->withToken($token)
        ->withHeader('X-Device-Id', $device->identifier);

    return [$user, $token];
}

test('a user can register via the v1 api', function (): void {
    $response = $this->postJson('/api/v1/auth/register', apiRegisterPayload());

    $response->assertOk()
        ->assertJsonPath('success', true);

    OtpVerification::query()
        ->where('email', 'jean@example.com')
        ->where('purpose', 'register')
        ->update(['code' => Hash::make('123456')]);

    $verify = $this->postJson('/api/v1/auth/verify-otp', [
        'email' => 'jean@example.com',
        'purpose' => 'register',
        'code' => '123456',
    ]);

    $verify->assertCreated()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.email', 'jean@example.com')
        ->assertJsonPath('data.token_type', 'Bearer')
        ->assertJsonStructure([
            'success',
            'message',
            'data' => [
                'user' => ['name', 'email', 'phone_number'],
                'access_token',
                'refresh_token',
                'token_type',
            ],
        ]);

    $this->assertDatabaseHas('users', [
        'email' => 'jean@example.com',
    ]);
});

test('registration requires unique email and phone number', function (): void {
    User::factory()->create([
        'email' => 'taken@example.com',
        'phone_number' => '+2250700000002',
    ]);

    $response = $this->postJson('/api/v1/auth/register', apiRegisterPayload([
        'email' => 'taken@example.com',
        'phone_number' => '0700000002',
        'device_id' => 'device-auth-002',
        'fcm_token' => 'fcm-auth-token-2',
    ]));

    $response->assertUnprocessable()
        ->assertJsonValidationErrors(['email', 'phone_number']);
});

test('a user can login with email', function (): void {
    $user = User::factory()->create([
        'email' => 'login@example.com',
        'phone_number' => '+2250700000003',
        'password' => Hash::make('password123'),
        'statut' => 'actif',
    ]);

    $response = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload('login@example.com', 'password123', 'device-login-email')
    );

    $response->assertOk()
        ->assertJsonPath('success', true);

    OtpVerification::query()
        ->where('email', $user->email)
        ->where('purpose', 'login')
        ->update(['code' => Hash::make('123456')]);

    $verify = $this->postJson('/api/v1/auth/verify-otp', [
        'email' => $user->email,
        'purpose' => 'login',
        'code' => '123456',
    ]);

    $verify->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.email', $user->email)
        ->assertJsonStructure([
            'data' => ['user', 'access_token', 'refresh_token', 'token_type'],
        ]);
});

test('a user can login with phone number', function (): void {
    $user = User::factory()->create([
        'email' => 'phone@example.com',
        'phone_number' => '+2250700000004',
        'password' => Hash::make('password123'),
        'statut' => 'actif',
    ]);

    $response = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload('+2250700000004', 'password123', 'device-login-phone')
    );

    $response->assertOk()->assertJsonPath('success', true);

    OtpVerification::query()
        ->where('email', $user->email)
        ->where('purpose', 'login')
        ->update(['code' => Hash::make('123456')]);

    $this->postJson('/api/v1/auth/verify-otp', [
        'email' => $user->email,
        'purpose' => 'login',
        'code' => '123456',
    ])
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.phone_number', '+2250700000004');
});

test('login fails with invalid credentials', function (): void {
    User::factory()->create([
        'email' => 'wrong@example.com',
        'phone_number' => '+2250700000005',
        'password' => Hash::make('password123'),
    ]);

    $response = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload('wrong@example.com', 'bad-password', 'device-login-bad')
    );

    $response->assertUnprocessable()
        ->assertJsonValidationErrors(['login']);
});

test('inactive users cannot login', function (): void {
    User::factory()->create([
        'email' => 'inactive@example.com',
        'phone_number' => '+2250700000006',
        'password' => Hash::make('password123'),
        'statut' => 'inactif',
    ]);

    $response = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload('inactive@example.com', 'password123', 'device-login-inactive')
    );

    $response->assertForbidden()
        ->assertJsonPath('success', false);
});

test('authenticated user can fetch me and logout', function (): void {
    [$user, $token] = authUserWithAccessToken([
        'phone_number' => '+2250700000007',
    ]);

    $this->getJson('/api/v1/auth/me')
        ->assertOk()
        ->assertJsonPath('success', true)
        ->assertJsonPath('data.user.email', $user->email);

    $this->getJson('/api/v1/user')
        ->assertOk()
        ->assertJsonPath('data.user.email', $user->email);

    $this->postJson('/api/v1/auth/logout')
        ->assertOk()
        ->assertJsonPath('success', true);

    $this->assertDatabaseCount('personal_access_tokens', 0);

    $this->app['auth']->forgetGuards();

    $this->withToken($token)
        ->withHeader('X-Device-Id', 'device-auth-session')
        ->getJson('/api/v1/auth/me')
        ->assertUnauthorized();
});

test('authenticated user can change password', function (): void {
    [$user] = authUserWithAccessToken([
        'phone_number' => '+2250700000008',
        'password' => Hash::make('password123'),
    ]);

    $user->createToken('other-device', ['access-api']);

    $this->putJson('/api/v1/auth/password', [
        'current_password' => 'password123',
        'password' => 'new-password123',
        'password_confirmation' => 'new-password123',
    ])
        ->assertOk()
        ->assertJsonPath('success', true);

    $user->refresh();

    expect(Hash::check('new-password123', $user->password))->toBeTrue()
        ->and(Hash::check('password123', $user->password))->toBeFalse();

    // Rotation : tous les anciens tokens sont révoqués, puis access + refresh sont recréés.
    $this->assertDatabaseCount('personal_access_tokens', 2);

    $this->app['auth']->forgetGuards();

    $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload($user->email, 'new-password123', 'device-after-password')
    )->assertOk();
});

test('change password rejects invalid current password', function (): void {
    authUserWithAccessToken([
        'phone_number' => '+2250700000009',
        'password' => Hash::make('password123'),
    ]);

    $this->putJson('/api/v1/auth/password', [
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
        'phone_number' => '+2250700000010',
        'password' => Hash::make('password123'),
        'statut' => 'actif',
    ]);

    $unknownResponse = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload('unknown@example.com', 'password123', 'device-unknown')
    );

    $adminResponse = $this->postJson(
        '/api/v1/auth/login',
        apiLoginDevicePayload($admin->email, 'password123', 'device-admin')
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
        'phone_number' => '+2250700000011',
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
