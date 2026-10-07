<?php

namespace App\Filament\Widgets;

use App\Models\User;
use App\Models\UserNumber;
use App\Models\Transaction;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;

class StatsOverviewWidget extends BaseWidget
{
    protected static ?int $sort = 1;

    protected function getStats(): array
    {
        $totalRevenue = Transaction::where('status', 'paid')->sum('amount');
        $activeNumbers = UserNumber::where('status', 'active')->count();
        $totalUsers = User::count();
        $activeSubscriptions = \App\Models\Subscription::where('status', 'active')->count();

        return [
            Stat::make('Total Revenue', '$' . number_format($totalRevenue, 2))
                ->description('Total earnings from all sales')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),

            Stat::make('Active Numbers', $activeNumbers)
                ->description('Virtual numbers currently in use')
                ->descriptionIcon('heroicon-m-phone')
                ->color('info'),

            Stat::make('Total Users', $totalUsers)
                ->description('Registered clients')
                ->descriptionIcon('heroicon-m-users')
                ->color('primary'),

            Stat::make('Active Subs', $activeSubscriptions)
                ->description('Current active plans')
                ->descriptionIcon('heroicon-m-credit-card')
                ->color('warning'),
        ];
    }
}
