<?php

namespace App\Filament\Widgets;

use App\Models\ObservabilityLog;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RequestTrafficChartWidget extends ChartWidget
{
    protected static ?int $sort = 4;

    public function getHeading(): string
    {
        return 'API Traffic Volume';
    }

    public function getDescription(): string
    {
        return 'Total number of requests processed per day';
    }

    protected function getData(): array
    {
        // Fetch total requests per day for the last 30 days
        $data = ObservabilityLog::where('created_at', '>=', now()->subDays(30))
            ->select([
                DB::raw('DATE(created_at) as date'),
                DB::raw('count(*) as total'),
            ])
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Total Requests',
                    'data' => $data->pluck('total')->toArray(),
                    'borderColor' => '#f59e0b', // Amber/Orange for traffic
                    'backgroundColor' => 'rgba(245, 158, 11, 0.1)',
                    'fill' => true,
                    'tension' => 0.4,
                ],
            ],
            'labels' => $data->pluck('date')->map(fn($date) => Carbon::parse($date)->format('d M'))->toArray(),
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
