<?php

namespace App\Mail;

use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Attachment;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Carbon;

class OtpCodeMail extends Mailable
{
    use Queueable, SerializesModels;

    public Carbon $expiresAt;

    public function __construct(
        public string $otp,
        public int $expiresInMinutes = 10,
    ) {
        $this->expiresAt = now()->addMinutes($expiresInMinutes);
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Votre code de vérification AfriNumber',
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'emails.otp',
            with: [
                'otp' => $this->otp,
                'expiresInMinutes' => $this->expiresInMinutes,
                'expiresAt' => $this->expiresAt,
                'expiresAtLabel' => $this->expiresAt
                    ->timezone(config('app.timezone'))
                    ->format('d/m/Y \à H:i'),
                'appName' => config('app.name', 'AfriNumber'),
            ],
        );
    }

    /**
     * @return array<int, Attachment>
     */
    public function attachments(): array
    {
        return [];
    }
}
