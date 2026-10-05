<?php

namespace App\Mail;

use App\Models\User;
use App\Support\Brand;
use App\Support\RecipientTimezone;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Attachment;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class AdminCredentialsMail extends Mailable
{
    use Queueable, SerializesModels;

    public string $recipientTimezone;

    public function __construct(
        public User $user,
        public string $plainPassword,
        public string $loginUrl,
    ) {
        if (! $this->user->relationLoaded('pays')) {
            $this->user->load('pays');
        }

        $this->recipientTimezone = RecipientTimezone::resolve(user: $this->user);
    }

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Votre compte '.Brand::name().' est prêt',
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'emails.admin-credentials',
            with: [
                'user' => $this->user,
                'plainPassword' => $this->plainPassword,
                'loginUrl' => $this->loginUrl,
                'appName' => Brand::name(),
                'logoWhiteUrl' => Brand::logoWhiteUrl(),
                'logoBlackUrl' => Brand::logoBlackUrl(),
                'recipientTimezone' => $this->recipientTimezone,
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