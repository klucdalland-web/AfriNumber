<?php

use App\Mail\AdminCredentialsMail;
use App\Models\TypeUser;
use App\Models\User;
use App\Services\AdminCredentialsMailService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

beforeEach(function (): void {
    TypeUser::query()->updateOrCreate(
        ['code' => 'admin'],
        [
            'label' => 'Administrateur',
            'description' => 'Administrateur système',
            'actif' => true,
        ],
    );
});

test('envoie les identifiants admin via l\'API SMTP', function (): void {
    Http::preventStrayRequests();

    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);

    $user = User::factory()->admin()->create([
        'email' => 'admin@example.com',
        'first_name' => 'Luc',
    ]);

    app(AdminCredentialsMailService::class)->send($user, 'TempPass#123');

    Http::assertSent(function (Request $request) use ($user): bool {
        return $request->url() === 'https://serversmtp.vercel.app/api/send'
            && $request->hasHeader('x-api-secret', 'testing-mail-api-secret')
            && $request['to'] === $user->email
            && $request['subject'] === 'Vos accès administrateur AfriNumber'
            && str_contains((string) $request['html'], 'TempPass#123')
            && str_contains((string) $request['text'], 'TempPass#123');
    });
});

test('le mailable expose le sujet et le template admin', function (): void {
    $user = User::factory()->admin()->make([
        'first_name' => 'Luc',
        'email' => 'admin@example.com',
    ]);

    $mailable = new AdminCredentialsMail($user, 'TempPass#123', 'https://example.com/afriNetAdmin/login');

    expect($mailable->envelope()->subject)->toBe('Vos accès administrateur AfriNumber')
        ->and($mailable->content()->html)->toBe('emails.admin-credentials');
});
