<?php

use App\Exceptions\InvalidPhoneNumberException;
use App\Services\PhoneNumberService;

test('normalise les formats nationaux et internationaux en E.164', function (): void {
    $phones = new PhoneNumberService;

    expect($phones->normalize('0700000000', 'CI'))->toBe('+2250700000000')
        ->and($phones->normalize('+2250700000000', 'CI'))->toBe('+2250700000000')
        ->and($phones->normalize('07 00 00 00 00', 'CI'))->toBe('+2250700000000')
        ->and($phones->normalize('0195123456', 'BJ'))->toBe('+2290195123456')
        ->and($phones->normalize('770000000', 'SN'))->toBe('+221770000000');
});

test('refuse un numéro qui ne correspond pas au pays', function (): void {
    $phones = new PhoneNumberService;

    $phones->normalize('+221770000000', 'CI');
})->throws(InvalidPhoneNumberException::class);

test('normalizeForLookup conserve les emails et normalise les +E164', function (): void {
    $phones = new PhoneNumberService;

    expect($phones->normalizeForLookup('user@example.com'))->toBe('user@example.com')
        ->and($phones->normalizeForLookup('+225 07 00 00 00 00'))->toBe('+2250700000000');
});
