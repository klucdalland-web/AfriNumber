<?php

namespace App\Rules;

use App\Exceptions\InvalidPhoneNumberException;
use App\Models\Pays;
use App\Services\PhoneNumberService;
use Closure;
use Illuminate\Contracts\Validation\DataAwareRule;
use Illuminate\Contracts\Validation\ValidationRule;

class PhoneNumberForPays implements DataAwareRule, ValidationRule
{
    /** @var array<string, mixed> */
    private array $data = [];

    public function __construct(
        private readonly ?string $paysIdField = 'contrie_id',
    ) {}

    /**
     * @param  array<string, mixed>  $data
     */
    public function setData(array $data): static
    {
        $this->data = $data;

        return $this;
    }

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if (! is_string($value) || $value === '') {
            $fail('Le numéro de téléphone est obligatoire.');

            return;
        }

        $paysId = $this->data[$this->paysIdField] ?? null;
        if (! $paysId) {
            $fail('Le pays est requis pour valider le numéro de téléphone.');

            return;
        }

        $pays = Pays::query()->find($paysId);
        if (! $pays) {
            $fail('Le pays sélectionné est invalide.');

            return;
        }

        try {
            app(PhoneNumberService::class)->normalize($value, $pays);
        } catch (InvalidPhoneNumberException $e) {
            $fail($e->getMessage());
        }
    }
}
