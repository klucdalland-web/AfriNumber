<?php

namespace App\Filament\Resources\NotificationCampaigns\Widgets;

use App\Models\NotificationCampaign;
use App\Models\NotificationDelivery;
use Filament\Support\Icons\Heroicon;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Database\Eloquent\Model;

class NotificationCampaignDeliveryStats extends StatsOverviewWidget
{
    protected static bool $isDiscovered = false;

    public ?Model $record = null;

    protected ?string $heading = 'Statistiques d\'envoi';

    protected ?string $pollingInterval = '30s';

    protected function getStats(): array
    {
        if (! $this->record instanceof NotificationCampaign) {
            return [];
        }

        $counts = NotificationDelivery::query()
            ->where('notification_campaign_id', $this->record->getKey())
            ->selectRaw('status, count(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $total = (int) $counts->sum();
        $sent = (int) ($counts[NotificationDelivery::STATUS_SENT] ?? 0);
        $failed = (int) ($counts[NotificationDelivery::STATUS_FAILED] ?? 0);
        $pending = (int) (
            ($counts[NotificationDelivery::STATUS_PENDING] ?? 0)
            + ($counts[NotificationDelivery::STATUS_PROCESSING] ?? 0)
        );
        $noToken = (int) ($counts[NotificationDelivery::STATUS_NO_TOKEN] ?? 0);
        $noEmail = (int) ($counts[NotificationDelivery::STATUS_NO_EMAIL] ?? 0);

        $decided = $sent + $failed;
        $successRate = $decided > 0
            ? round(($sent / $decided) * 100, 1).'%'
            : '—';

        $recipients = (int) ($this->record->stats['recipients'] ?? $this->record->users()->count());

        return [
            Stat::make('Destinataires', number_format($recipients > 0 ? $recipients : $total))
                ->description($total.' deliveries')
                ->descriptionIcon(Heroicon::OutlinedUsers)
                ->color('primary'),
            Stat::make('Envoyés', number_format($sent))
                ->descriptionIcon(Heroicon::OutlinedCheckCircle)
                ->color('success'),
            Stat::make('Échoués', number_format($failed))
                ->description(($noToken + $noEmail).' ignorés (token/e-mail)')
                ->descriptionIcon(Heroicon::OutlinedExclamationTriangle)
                ->color($failed > 0 ? 'danger' : 'gray'),
            Stat::make('Taux de succès', $successRate)
                ->description($pending.' en attente')
                ->descriptionIcon(Heroicon::OutlinedChartBar)
                ->color($decided === 0 ? 'gray' : ($sent / max($decided, 1) >= 0.9 ? 'success' : 'warning')),
        ];
    }
}
