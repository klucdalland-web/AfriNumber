<?php

namespace App\Mail;

use App\Models\User;
use App\Support\Brand;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Mail\Mailables\Content;
use Illuminate\Mail\Mailables\Envelope;
use Illuminate\Queue\SerializesModels;

class CampaignMessageMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public User $user,
        public string $mailSubject,
        public string $title,
        public string $body,
    ) {}

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: $this->mailSubject,
        );
    }

    public function content(): Content
    {
        return new Content(
            html: 'emails.campaign-message',
            with: [
                'firstName' => $this->user->first_name ?: $this->user->name,
                'title' => $this->title,
                'body' => $this->body,
                'appName' => Brand::name(),
                'logoBlackUrl' => Brand::logoBlackUrl(),
                'copyrightYear' => now()->format('Y'),
            ],
        );
    }
}
