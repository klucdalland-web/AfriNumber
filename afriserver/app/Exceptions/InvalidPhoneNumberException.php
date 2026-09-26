<?php

namespace App\Exceptions;

use RuntimeException;

class InvalidPhoneNumberException extends RuntimeException
{
    public function __construct(
        public readonly string $errorKey = 'phone_number',
        string $message = 'Le numéro de téléphone est invalide.',
    ) {
        parent::__construct($message);
    }
}
