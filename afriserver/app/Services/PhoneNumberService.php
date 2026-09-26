<?php

namespace App\Services;

use App\Exceptions\InvalidPhoneNumberException;
use App\Models\Pays;
use libphonenumber\NumberParseException;
use libphonenumber\PhoneNumberFormat;
use libphonenumber\PhoneNumberType;
use libphonenumber\PhoneNumberUtil;

class PhoneNumberService
{
    private PhoneNumberUtil $phoneUtil;

    public function __construct(?PhoneNumberUtil $phoneUtil = null)
    {
        $this->phoneUtil = $phoneUtil ?? PhoneNumberUtil::getInstance();
    }

    /**
     * Normalise un numéro en E.164 (+2250700000000) pour le pays donné.
     *
     * Accepte : "0700000000", "2250700000000", "+2250700000000", "07 00 00 00 00"
     *
     * @throws InvalidPhoneNumberException
     */
    public function normalize(string $raw, Pays|string $paysOrIso): string
    {
        $iso = $this->resolveIso($paysOrIso);
        $cleaned = $this->sanitize($raw);

        try {
            $number = $this->phoneUtil->parse($cleaned, $iso);
        } catch (NumberParseException) {
            throw new InvalidPhoneNumberException(message: 'Le numéro de téléphone est invalide.');
        }

        if (! $this->phoneUtil->isValidNumber($number)) {
            throw new InvalidPhoneNumberException(
                message: "Le numéro de téléphone n'est pas valide pour ce pays."
            );
        }

        if ($this->phoneUtil->getRegionCodeForNumber($number) !== $iso) {
            throw new InvalidPhoneNumberException(
                message: "Le numéro ne correspond pas à l'indicatif du pays sélectionné."
            );
        }

        $type = $this->phoneUtil->getNumberType($number);
        if (! in_array($type, [
            PhoneNumberType::MOBILE,
            PhoneNumberType::FIXED_LINE_OR_MOBILE,
            PhoneNumberType::FIXED_LINE,
        ], true)) {
            throw new InvalidPhoneNumberException(
                message: 'Le numéro de téléphone doit être un numéro mobile ou fixe valide.'
            );
        }

        return $this->phoneUtil->format($number, PhoneNumberFormat::E164);
    }

    public function isValid(string $raw, Pays|string $paysOrIso): bool
    {
        try {
            $this->normalize($raw, $paysOrIso);

            return true;
        } catch (InvalidPhoneNumberException) {
            return false;
        }
    }

    /**
     * Pour login / forgot : normalise un numéro déjà international (+...),
     * sinon retourne le raw nettoyé (email inchangé).
     */
    public function normalizeForLookup(?string $raw): ?string
    {
        if ($raw === null || trim($raw) === '') {
            return null;
        }

        $trimmed = trim($raw);

        if (str_contains($trimmed, '@')) {
            return $trimmed;
        }

        $cleaned = $this->sanitize($trimmed);

        try {
            if (str_starts_with($cleaned, '+')) {
                $number = $this->phoneUtil->parse($cleaned, null);

                if ($this->phoneUtil->isValidNumber($number)) {
                    return $this->phoneUtil->format($number, PhoneNumberFormat::E164);
                }
            }
        } catch (NumberParseException) {
            // fallback
        }

        return $cleaned;
    }

    public function formatNational(string $e164, Pays|string $paysOrIso): string
    {
        $iso = $this->resolveIso($paysOrIso);

        try {
            $number = $this->phoneUtil->parse($e164, $iso);

            return $this->phoneUtil->format($number, PhoneNumberFormat::NATIONAL);
        } catch (NumberParseException) {
            return $e164;
        }
    }

    public function formatInternational(string $e164): string
    {
        try {
            $number = $this->phoneUtil->parse($e164, null);

            return $this->phoneUtil->format($number, PhoneNumberFormat::INTERNATIONAL);
        } catch (NumberParseException) {
            return $e164;
        }
    }

    private function resolveIso(Pays|string $paysOrIso): string
    {
        if ($paysOrIso instanceof Pays) {
            $code = strtoupper((string) $paysOrIso->code);

            if ($code === '') {
                throw new InvalidPhoneNumberException(
                    errorKey: 'contrie_id',
                    message: 'Le pays sélectionné est invalide.'
                );
            }

            return $code;
        }

        return strtoupper($paysOrIso);
    }

    private function sanitize(string $raw): string
    {
        $raw = trim($raw);
        $raw = preg_replace('/[^\d+]/', '', $raw) ?? $raw;

        if (str_contains($raw, '+')) {
            $digits = preg_replace('/\D/', '', $raw) ?? '';
            $raw = '+'.$digits;
        }

        return $raw;
    }
}
