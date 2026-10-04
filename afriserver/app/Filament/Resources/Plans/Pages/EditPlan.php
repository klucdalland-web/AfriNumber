<?php

namespace App\Filament\Resources\Plans\Pages;

use App\Filament\Resources\Plans\Concerns\SyncsPlanServices;
use App\Filament\Resources\Plans\PlanResource;
use App\Models\Plan;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditPlan extends EditRecord
{
    use SyncsPlanServices;

    protected static string $resource = PlanResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make(),
        ];
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeFill(array $data): array
    {
        /** @var Plan $plan */
        $plan = $this->record;
        $plan->load('services');

        $data['serviceAttachments'] = $this->serviceAttachmentsFromRecord($plan);

        return $data;
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function mutateFormDataBeforeSave(array $data): array
    {
        return $this->extractServiceAttachments($data);
    }

    protected function afterSave(): void
    {
        /** @var Plan $plan */
        $plan = $this->record;

        $this->syncPendingServiceAttachments($plan);
    }
}
