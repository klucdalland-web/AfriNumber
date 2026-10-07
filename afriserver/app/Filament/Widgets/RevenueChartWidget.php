<?php

namespace App\Filament\Widgets;

use App\Models\Transaction;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class RevenueChartWidget extends ChartWidget
{
    protected static ?int $sort = 2;

    public function getHeading(): string
    {
        return 'Revenue Over Time';
    }

    public function getDescription(): string
    {
        return 'Daily revenue from paid transactions';
    }

    protected function getData(): array
    {
        // Fetch daily revenue for the last 30 days
        $data = Transaction::where('status', 'paid')
            ->where('created_at', '>=', now()->subDays(30))
            ->select([
                DB::raw('DATE(created_at) as date'),
                DB::raw('SUM(amount) as total'),
            ])
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        return [
            'datasets' => [
                [
                    'label' => 'Revenue ($)',
                    'data' => $data->pluck('total')->toArray(),
                    'borderColor' => '#10b981',
                    'backgroundColor' => 'rgba(16, 185, 129, 0.1)',
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
