@php
    $record = $getRecord();
    $location = is_array($record?->location) ? $record->location : null;
    $latitude = isset($location['latitude']) && is_numeric($location['latitude']) ? (float) $location['latitude'] : null;
    $longitude = isset($location['longitude']) && is_numeric($location['longitude']) ? (float) $location['longitude'] : null;
    $label = \App\Support\GeoMapUrl::label($location);
@endphp

@if ($latitude === null || $longitude === null)
    <p class="text-sm text-gray-500 dark:text-gray-400">
        Coordonnées indisponibles pour afficher la carte.
        @if ($label)
            <span class="block mt-1">{{ $label }}</span>
        @endif
    </p>
@else
    @php
        $embedUrl = \App\Support\GeoMapUrl::openStreetMapEmbed($latitude, $longitude);
        $mapsUrl = \App\Support\GeoMapUrl::googleMaps($latitude, $longitude);
    @endphp

    <div class="space-y-3 w-full">
        @if ($label)
            <p class="text-sm font-medium text-gray-950 dark:text-white">{{ $label }}</p>
        @endif

        <div class="overflow-hidden rounded-xl border border-gray-200 dark:border-gray-700">
            <iframe
                title="Carte de localisation"
                src="{{ $embedUrl }}"
                class="h-72 w-full"
                loading="lazy"
                referrerpolicy="no-referrer-when-downgrade"
            ></iframe>
        </div>

        <div class="flex flex-wrap gap-3 text-sm">
            <a
                href="{{ $mapsUrl }}"
                target="_blank"
                rel="noopener noreferrer"
                class="font-medium text-primary-600 underline decoration-primary-600/30 underline-offset-2 hover:decoration-primary-600 dark:text-primary-400"
            >
                Ouvrir dans Google Maps
            </a>
            <a
                href="https://www.openstreetmap.org/?mlat={{ $latitude }}&amp;mlon={{ $longitude }}#map=14/{{ $latitude }}/{{ $longitude }}"
                target="_blank"
                rel="noopener noreferrer"
                class="font-medium text-primary-600 underline decoration-primary-600/30 underline-offset-2 hover:decoration-primary-600 dark:text-primary-400"
            >
                Ouvrir dans OpenStreetMap
            </a>
        </div>
    </div>
@endif
