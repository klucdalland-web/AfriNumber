<?php

namespace App\Http\Requests\Api\V1\Auth;

use Illuminate\Foundation\Http\FormRequest;

class LoginRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    /**
     * @return array<string, mixed>
     */
    public function rules(): array
    {
        return [
            'email' => ['required', 'string', 'max:255'],
            'password' => ['required', 'string'],
            'device_name' => ['nullable', 'string', 'max:255'],
            'platform' => ['required', 'string', 'in:android,ios,web'],
            'device_id' => ['required', 'string'],
            'device_model' => ['required', 'string', 'max:100'],
            'os_version' => ['required', 'string', 'max:50'],
            'app_version' => ['required', 'string', 'max:20'],
            'fcm_token' => ['required', 'string', 'max:1000'],

        ];
    }
}
