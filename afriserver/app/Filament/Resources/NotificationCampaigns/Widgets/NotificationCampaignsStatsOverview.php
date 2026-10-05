<?php

namespace App\Filament\Resources\NotificationCampaigns\Widgets;

use App\Models\NotificationCampaign;
use App\Models\NotificationDelivery;
use Filament\Support\Icons\Heroicon;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class NotificationCampaignsStatsOverview extends StatsOverviewWidget
{
    protected static bool $isDiscovered = false;

    protected ?string $heading = 'Statistiques notifications';

    protected ?string $pollingInterval = '60s';

    protected function getStats(): array
    {
        $campaignCounts = NotificationCampaign::query()
            ->selectRaw('status, count(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $deliveryCounts = NotificationDelivery::query()
            ->selectRaw('status, count(*) as aggregate')
            ->groupBy('status')
            ->pluck('aggregate', 'status');

        $totalCampaigns = (int) $campaignCounts->sum();
        $activeCampaigns = (int) (
            ($campaignCounts[NotificationCampaign::STATUS_SCHEDULED] ?? 0)
            + ($campaignCounts[NotificationCampaign::STATUS_QUEUED] ?? 0)
            + ($campaignCounts[NotificationCampaign::STATUS_PROCESSING] ?? 0)
        );

        $sent = (int) ($deliveryCounts[NotificationDelivery::STATUS_SENT] ?? 0);
        $failed = (int) ($deliveryCounts[NotificationDelivery::STATUS_FAILED] ?? 0);
        $pending = (int) (
            ($deliveryCounts[NotificationDelivery::STATUS_PENDING] ?? 0)
            + ($deliveryCounts[NotificationDelivery::STATUS_PROCESSING] ?? 0)
        );
        $skipped = (int) (
            ($deliveryCounts[NotificationDelivery::STATUS_NO_TOKEN] ?? 0)
            + ($deliveryCounts[NotificationDelivery::STATUS_NO_EMAIL] ?? 0)
        );

        $decided = $sent + $failed;
        $successRate = $decided > 0
            ? round(($sent / $decided) * 100, 1).'%'
            : '—';

        $sentLast7Days = NotificationDelivery::query()
            ->where('status', NotificationDelivery::STATUS_SENT)
            ->where('processed_at', '>=', now()->subDays(6)->startOfDay())
            ->get(['processed_at'])
            ->groupBy(fn (NotificationDelivery $delivery): string => $delivery->processed_at?->toDateString() ?? '')
            ->map->count();

        $chart = [];
        for ($i = 6; $i >= 0; $i--) {
            $day = now()->subDays($i)->toDateString();
            $chart[] = (float) ($sentLast7Days[$day] ?? 0);
        }

        $sentToday = NotificationDelivery::query()
            ->where('status', NotificationDelivery::STATUS_SENT)
            ->whereDate('processed_at', today())
            ->count();

        return [
            Stat::make('Campagnes', number_format($totalCampaigns))
                ->description($activeCampaigns.' en cours / planifiées')
                ->descriptionIcon(Heroicon::OutlinedMegaphone)
                ->color('primary'),
            Stat::make('Envoyés', number_format($sent))
                ->description($sentToday.' aujourd\'hui · 7 derniers jours')
                ->descriptionIcon(Heroicon::OutlinedCheckCircle)
                ->chart($chart)
                ->color('success'),
            Stat::make('Échoués', number_format($failed))
                ->description($skipped.' sans token / e-mail')
                ->descriptionIcon(Heroicon::OutlinedExclamationTriangle)
                ->color($failed > 0 ? 'danger' : 'gray'),
            Stat::make('Taux de succès', $successRate)
                ->description($pending.' en attente')
                ->descriptionIcon(Heroicon::OutlinedChartBar)
                ->color($decided === 0 ? 'gray' : ($sent / max($decided, 1) >= 0.9 ? 'success' : 'warning')),
        ];
    }
}
