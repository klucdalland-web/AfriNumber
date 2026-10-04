<?php

namespace App\Filament\Resources\Plans\Pages;

use App\Filament\Resources\Plans\Concerns\SyncsPlanServices;
use App\Filament\Resources\Plans\PlanResource;
use App\Models\Plan;
use Filament\Resources\Pages\CreateRecord;

class CreatePlan extends CreateRecord
{
    use SyncsPlanServices;

    protected static string $resource = PlanResource::class;

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeCreate(array $data): array
    {
        return $this->extractServiceAttachments($data);
    }

    protected function afterCreate(): void
    {
        /** @var Plan $plan */
        $plan = $this->record;

        $this->syncPendingServiceAttachments($plan);
    }
}
