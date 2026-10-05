<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Identité AfriNumber / AfriNet
    |--------------------------------------------------------------------------
    | Aligné sur le design afri_web (fond crème, texte sombre, logos Afrika).
    */

    'name' => env('APP_NAME', 'AfriNumber'),

    'logos' => [
        'white' => 'logo-afrika-white.png',
        'black' => 'logo-afrika-black.png',
    ],

    /*
    | Approx. hex des tokens oklch de afri_web/app/globals.css (:root).
    */
    'colors' => [
        'background' => '#F6F4EF',
        'foreground' => '#1C1A17',
        'card' => '#FCFAF7',
        'muted' => '#EDE9E1',
        'muted_foreground' => '#6B655C',
        'border' => '#D4CFC4',
        'primary' => '#1C1A17',
        'primary_foreground' => '#F6F4EF',
        'accent' => '#E5DFD2',
        'warning' => '#8A6A28',
        'warning_bg' => '#F4EBD8',
        'warning_border' => '#D9C48A',
    ],

];
