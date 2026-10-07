<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Resend, Postmark, AWS, and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],
    'discord' => [
        'alert_webhook' => env('DISCORD_ALERT_WEBHOOK'),
    ],
    'zavu' => [
        'key' => env('ZAVU_API_KEY'),
        'base_url' => 'https://zavu.dev',
    ],

    'verifiedcore' => [
        'key' => env('VERIFIEDCORE_API_KEY'),
        'base_url' => env('VERIFIEDCORE_BASE_URL', 'https://api.verifiedcore.com/v1'),
    ],

    'numbers' => [
        'default_provider' => env('NUMBER_PROVIDER', 'mock'),
    ],

    'mail_api' => [
        'url' => env('MAIL_API_URL', 'https://serversmtp.vercel.app/api/send'),
        'secret' => env('MAIL_API_SECRET'),
    ],
    'internal' => [
        'secret' => env('SERVICE_SECRET_KEY'),
        'n8n_url' => env('N8N_WEBHOOK_URL'),
    ],
    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

];
