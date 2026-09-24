<?php

namespace App\Http\Requests\Api\V1\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class ForgotPasswordRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'email' => ['nullable', 'required_without:phone_number', 'string', 'email', 'max:255'],
            'phone_number' => ['nullable', 'required_without:email', 'string', 'max:30'],
        ];
    }
}