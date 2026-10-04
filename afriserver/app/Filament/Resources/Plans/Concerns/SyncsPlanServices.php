<?php

namespace App\Filament\Resources\Plans\Concerns;

use App\Models\Plan;
use Illuminate\Support\Arr;

trait SyncsPlanServices
{
    /**
     * @var list<array{service_id: int, quota: int|null}>
     */
    protected array $pendingServiceAttachments = [];

    /**
     * @return list<array{service_id: int, quota: int|null}>
     */
    protected function serviceAttachmentsFromRecord(Plan $plan): array
    {
        return $plan->services
            ->map(fn ($service): array => [
                'service_id' => $service->id,
                'quota' => $service->pivot->quota !== null ? (int) $service->pivot->quota : null,
            ])
            ->values()
            ->all();
    }

    /**
     * @param  array<string, mixed>  $data
     * @return array<string, mixed>
     */
    protected function extractServiceAttachments(array $data): array
    {
        /** @var list<array{service_id?: mixed, quota?: mixed}> $attachments */
        $attachments = $data['serviceAttachments'] ?? [];

        $this->pendingServiceAttachments = [];

        foreach ($attachments as $row) {
            $serviceId = (int) Arr::get($row, 'service_id');

            if ($serviceId <= 0) {
                continue;
            }

            $quota = Arr::get($row, 'quota');

            $this->pendingServiceAttachments[] = [
                'service_id' => $serviceId,
                'quota' => $quota === null || $quota === '' ? null : (int) $quota,
            ];
        }

        unset($data['serviceAttachments']);

        return $data;
    }

    protected function syncPendingServiceAttachments(Plan $plan): void
    {
        $sync = [];

        foreach ($this->pendingServiceAttachments as $row) {
            $sync[$row['service_id']] = ['quota' => $row['quota']];
        }

        $plan->services()->sync($sync);
    }
}
