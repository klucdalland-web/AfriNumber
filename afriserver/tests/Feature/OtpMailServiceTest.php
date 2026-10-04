<?php

use App\Mail\OtpCodeMail;
use App\Services\OtpMailService;
use Illuminate\Support\Facades\Mail;

test('envoie un e-mail OTP à l\'adresse indiquée', function (): void {
    Mail::fake();

    app(OtpMailService::class)->send('luc@example.com', '482913', 10);

    Mail::assertSent(OtpCodeMail::class, function (OtpCodeMail $mail): bool {
        return $mail->hasTo('luc@example.com')
            && $mail->otp === '482913'
            && $mail->expiresInMinutes === 10;
    });
});

test('le mailable expose le sujet AfriNumber et une date d\'expiration', function (): void {
    $mailable = new OtpCodeMail('123456', 10);

    expect($mailable->envelope()->subject)->toBe('Votre code de vérification AfriNumber')
        ->and($mailable->content()->html)->toBe('emails.otp')
        ->and($mailable->expiresAt->isAfter(now()->addMinutes(9)))->toBeTrue()
        ->and($mailable->expiresAt->isBefore(now()->addMinutes(11)))->toBeTrue();
});
