<?php

use App\Models\FraisTransaction;
use Tests\TestCase;

uses(TestCase::class);

it('calcule les frais sans min ni max', function (): void {
    $frais = new FraisTransaction([
        'montant_fixe' => '0.50000000',
        'taux_pourcentage' => '1.0000',
        'montant_min' => null,
        'montant_max' => null,
    ]);

    expect($frais->calculer('100'))->toBe('1.50000000');
});

it('applique le montant minimum lorsqu il est défini', function (): void {
    $frais = new FraisTransaction([
        'montant_fixe' => '0.00000000',
        'taux_pourcentage' => '1.0000',
        'montant_min' => '1.00000000',
        'montant_max' => null,
    ]);

    expect($frais->calculer('10'))->toBe('1.00000000');
});

it('applique le montant maximum lorsqu il est défini', function (): void {
    $frais = new FraisTransaction([
        'montant_fixe' => '0.00000000',
        'taux_pourcentage' => '10.0000',
        'montant_min' => null,
        'montant_max' => '2.00000000',
    ]);

    expect($frais->calculer('100'))->toBe('2.00000000');
});

it('calcule uniquement le montant fixe lorsque le taux est zero', function (): void {
    $frais = new FraisTransaction([
        'montant_fixe' => '0.25000000',
        'taux_pourcentage' => '0.0000',
        'montant_min' => null,
        'montant_max' => null,
    ]);

    expect($frais->calculer('999'))->toBe('0.25000000');
});
