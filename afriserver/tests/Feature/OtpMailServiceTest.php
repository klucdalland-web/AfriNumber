<?php

use App\Mail\OtpCodeMail;
use App\Services\OtpMailService;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

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
