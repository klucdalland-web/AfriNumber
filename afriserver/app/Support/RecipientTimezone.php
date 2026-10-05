<?php

namespace App\Support;

use App\Models\Pays;
use App\Models\User;
use DateTimeInterface;
use DateTimeZone;
use Illuminate\Support\Carbon;

class RecipientTimezone
{
    /**
     * Résout le fuseau IANA du destinataire (pays du user / pays explicite / défaut app).
     */
    public static function resolve(
        ?User $user = null,
        ?Pays $pays = null,
        ?string $countryCode = null,
        ?int $paysId = null,
    ): string {
        $resolvedPays = $pays
            ?? ($paysId !== null ? Pays::query()->find($paysId) : null)
            ?? ($user?->relationLoaded('pays') ? $user->pays : $user?->pays()->first())
            ?? (filled($countryCode)
                ? Pays::query()->where('code', strtoupper($countryCode))->first()
                : null);

        $timezone = $resolvedPays?->timezone;

        if (filled($timezone) && self::isValid($timezone)) {
            return $timezone;
        }

        $fallback = (string) config('app.timezone', 'UTC');

        return self::isValid($fallback) ? $fallback : 'UTC';
    }

    public static function isValid(string $timezone): bool
    {
        try {
            new DateTimeZone($timezone);

            return true;
        } catch (\Exception) {
            return false;
        }
    }

    /**
     * Formate une date/heure dans le fuseau du destinataire.
     * Ex. : « 04/10/2026 à 18:10 (heure de Madagascar) »
     */
    public static function format(
        DateTimeInterface|string $date,
        string $timezone,
        ?string $countryLabel = null,
        string $pattern = 'd/m/Y \à H:i',
    ): string {
        $local = Carbon::parse($date)->timezone($timezone);
        $label = $local->format($pattern);

        if (filled($countryLabel)) {
            return "{$label} (heure de {$countryLabel})";
        }

        return "{$label} ({$local->format('T')})";
    }

    /**
     * Label prêt pour les e-mails, avec le pays du destinataire si connu.
     */
    public static function formatForRecipient(
        DateTimeInterface|string $date,
        ?User $user = null,
        ?Pays $pays = null,
        ?string $countryCode = null,
        ?int $paysId = null,
    ): string {
        $resolvedPays = $pays
            ?? ($paysId !== null ? Pays::query()->find($paysId) : null)
            ?? ($user?->relationLoaded('pays') ? $user->pays : $user?->pays()->first())
            ?? (filled($countryCode)
                ? Pays::query()->where('code', strtoupper($countryCode))->first()
                : null);

        $timezone = self::resolve(
            user: $user,
            pays: $resolvedPays,
            countryCode: $countryCode,
            paysId: $paysId,
        );

        return self::format(
            $date,
            $timezone,
            $resolvedPays?->label,
        );
    }
}
