<?php

use App\Mail\AdminCredentialsMail;
use App\Models\Pays;
use App\Models\TypeUser;
use App\Models\User;
use App\Services\AdminCredentialsMailService;
use App\Support\Brand;
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
            && $request['subject'] === 'Votre compte AfriNumber est prêt'
            && str_contains((string) $request['html'], 'TempPass#123')
            && str_contains((string) $request['text'], 'TempPass#123')
            && ! str_contains((string) $request['html'], 'Envoyé le');
    });
});

test('le mailable admin utilise le fuseau du pays sans afficher Envoyé le', function (): void {
    $pays = Pays::factory()->create([
        'label' => 'Kenya',
        'code' => 'KE',
        'timezone' => 'Africa/Nairobi',
    ]);

    $user = User::factory()->admin()->create([
        'first_name' => 'Amina',
        'email' => 'amina@example.com',
        'pays_id' => $pays->id,
    ])->load('pays');

    $mailable = new AdminCredentialsMail($user, 'TempPass#123', 'https://example.com/afriNetAdmin/login');

    expect($mailable->envelope()->subject)->toBe('Votre compte AfriNumber est prêt')
        ->and($mailable->content()->html)->toBe('emails.admin-credentials')
        ->and($mailable->recipientTimezone)->toBe('Africa/Nairobi')
        ->and($mailable->render())->not->toContain('Envoyé le');
});

test('le mailable admin inclut le logo AfriNet et le design afri_web', function (): void {
    $user = User::factory()->admin()->create([
        'first_name' => 'Luc',
        'email' => 'luc-brand@example.com',
    ]);

    $mailable = new AdminCredentialsMail($user, 'TempPass#123', 'https://example.com/afriNetAdmin/login');
    $html = $mailable->render();

    expect($html)->toContain(Brand::logoWhiteUrl())
        ->and($html)->toContain('#F6F4EF')
        ->and($html)->toContain('#1C1A17')
        ->and($html)->toContain('logo-afrika-white.png')
        ->and($html)->not->toContain('Envoyé le');
});
