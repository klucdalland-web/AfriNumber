<?php

namespace App\Mail;

use App\Models\Pays;
use App\Models\User;
use App\Support\Brand;
use App\Support\RecipientTimezone;
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

    public string $recipientTimezone;

    public ?string $recipientCountryLabel;

    public string $expiresAtLabel;

    public function __construct(
        public string $otp,
        public int $expiresInMinutes = 10,
        ?User $user = null,
        ?Pays $pays = null,
        ?string $countryCode = null,
        ?int $paysId = null,
    ) {
        $resolvedPays = $pays
            ?? ($paysId !== null ? Pays::query()->find($paysId) : null)
            ?? ($user?->relationLoaded('pays') ? $user->pays : $user?->pays()->first())
            ?? (filled($countryCode)
                ? Pays::query()->where('code', strtoupper($countryCode))->first()
                : null);

        $this->expiresAt = now()->addMinutes($expiresInMinutes);
        $this->recipientTimezone = RecipientTimezone::resolve(
            user: $user,
            pays: $resolvedPays,
            countryCode: $countryCode,
            paysId: $paysId,
        );
        $this->recipientCountryLabel = $resolvedPays?->label;
        $this->expiresAtLabel = RecipientTimezone::format(
            $this->expiresAt,
            $this->recipientTimezone,
            $this->recipientCountryLabel,
        );
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Votre code de vérification '.Brand::name(),
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
                'expiresAtLabel' => $this->expiresAtLabel,
                'recipientTimezone' => $this->recipientTimezone,
                'appName' => Brand::name(),
                'logoWhiteUrl' => Brand::logoWhiteUrl(),
                'logoBlackUrl' => Brand::logoBlackUrl(),
                'copyrightYear' => now()->timezone($this->recipientTimezone)->format('Y'),
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
