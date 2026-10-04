<?php

use App\Mail\OtpCodeMail;
use App\Models\Pays;
use App\Models\User;
use App\Services\OtpMailService;
use App\Support\Brand;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Http;

uses(RefreshDatabase::class);

test('envoie un e-mail OTP via l\'API SMTP', function (): void {
    Http::preventStrayRequests();

    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);

    app(OtpMailService::class)->send('luc@example.com', '482913', 10);

    Http::assertSent(function (Request $request): bool {
        return $request->url() === 'https://serversmtp.vercel.app/api/send'
            && $request->hasHeader('x-api-secret', 'testing-mail-api-secret')
            && $request['to'] === 'luc@example.com'
            && $request['subject'] === 'Votre code de vérification AfriNumber'
            && str_contains((string) $request['html'], '482913')
            && str_contains((string) $request['text'], '482913');
    });
});

test('le mailable expose le sujet AfriNumber et une date d\'expiration', function (): void {
    $mailable = new OtpCodeMail('123456', 10);

    expect($mailable->envelope()->subject)->toBe('Votre code de vérification AfriNumber')
        ->and($mailable->content()->html)->toBe('emails.otp')
        ->and($mailable->expiresAt->isAfter(now()->addMinutes(9)))->toBeTrue()
        ->and($mailable->expiresAt->isBefore(now()->addMinutes(11)))->toBeTrue();
});

test('la date d\'expiration OTP utilise le fuseau du pays du destinataire', function (): void {
    Carbon::setTestNow(Carbon::parse('2026-10-04 17:00:00', 'UTC'));

    $pays = Pays::factory()->create([
        'label' => 'Madagascar',
        'code' => 'MG',
        'timezone' => 'Indian/Antananarivo',
    ]);

    $mailable = new OtpCodeMail(
        otp: '654321',
        expiresInMinutes: 10,
        pays: $pays,
    );

    expect($mailable->recipientTimezone)->toBe('Indian/Antananarivo')
        ->and($mailable->expiresAtLabel)->toBe('04/10/2026 à 20:10 (heure de Madagascar)');

    $html = $mailable->render();

    expect($html)->toContain('04/10/2026 à 20:10 (heure de Madagascar)');

    Carbon::setTestNow();
});

test('OtpMailService résout le fuseau via le pays de l\'utilisateur', function (): void {
    Carbon::setTestNow(Carbon::parse('2026-10-04 12:00:00', 'UTC'));

    Http::preventStrayRequests();
    Http::fake([
        'serversmtp.vercel.app/api/send' => Http::response(['ok' => true], 200),
    ]);

    $pays = Pays::factory()->create([
        'label' => 'Sénégal',
        'code' => 'SN',
        'timezone' => 'Africa/Dakar',
    ]);

    $user = User::factory()->create([
        'email' => 'awa@example.com',
        'pays_id' => $pays->id,
    ]);

    app(OtpMailService::class)->send(
        email: $user->email,
        otp: '111222',
        expiresInMinutes: 15,
        user: $user->load('pays'),
    );

    Http::assertSent(function (Request $request): bool {
        return str_contains((string) $request['html'], '04/10/2026 à 12:15 (heure de Sénégal)')
            && str_contains((string) $request['text'], '04/10/2026 à 12:15 (heure de Sénégal)');
    });

    Carbon::setTestNow();
});

test('le mailable OTP inclut le logo AfriNet et le design afri_web', function (): void {
    $mailable = new OtpCodeMail('123456', 10);
    $html = $mailable->render();

    expect($html)->toContain(Brand::logoWhiteUrl())
        ->and($html)->toContain('#F6F4EF')
        ->and($html)->toContain('#1C1A17')
        ->and($html)->toContain('logo-afrika-white.png');
});
