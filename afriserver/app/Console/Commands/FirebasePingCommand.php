<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;
use Throwable;

class FirebasePingCommand extends Command
{
    protected $signature = 'firebase:ping {--token= : Token FCM optionnel pour un envoi test}';

    protected $description = 'Vérifie que les credentials Firebase sont chargés et que FCM répond';

    public function handle(Messaging $messaging): int
    {
        $configured = config('firebase.projects.app.credentials');
        $this->line('FIREBASE_CREDENTIALS config = '.json_encode($configured));

        if (is_string($configured) && $configured !== '') {
            $path = str_starts_with($configured, '/') || str_contains($configured, ':\\')
                ? $configured
                : base_path($configured);
            $this->line('Resolved path = '.$path);
            $this->line('File exists  = '.(is_file($path) ? 'yes' : 'NO'));
        } else {
            $this->warn('Aucun chemin credentials configuré (env FIREBASE_CREDENTIALS vide).');
        }

        $token = $this->option('token');
        if (! is_string($token) || $token === '') {
            $this->info('Credentials inspectés. Passe --token=... pour un envoi FCM réel.');

            return self::SUCCESS;
        }

        try {
            $message = CloudMessage::new()
                ->withNotification(Notification::create('AfriNumber ping', 'Test FCM serveur '.now()->toDateTimeString()));

            $report = $messaging->sendMulticast($message, [$token]);
            $this->info('success='.$report->successes()->count().' failure='.$report->failures()->count());

            foreach ($report->failures() as $failure) {
                $this->error('fail: '.$failure->error()?->getMessage());
            }

            return $report->successes()->count() > 0 ? self::SUCCESS : self::FAILURE;
        } catch (Throwable $e) {
            $this->error('Exception FCM: '.$e->getMessage());

            return self::FAILURE;
        }
    }
}
