<?php

namespace App\Http\Requests\Api\V1\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rules\Password;

class RegisterRequest extends FormRequest
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
            'contrie_id' => ['required', 'integer', 'exists:pays,id'],
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'phone_number' => ['required', 'string', 'max:30', 'unique:users,phone_number'],
            'password' => ['required', 'string', 'confirmed', Password::defaults()],
            'type_user_id' => ['nullable', 'integer', 'exists:type_users,id'],
            'device_name' => ['nullable', 'string', 'max:255'],
            'first_name' => ['required', 'string', 'max:255'],
            
        ];
    }
    public function messages(): array
{
    return [
        'contrie_id.exists' => 'Le pays sélectionné est invalide.',

        // Messages pour le nom
        'name.required' => 'Le nom est obligatoire.',
        'name.string' => 'Le nom doit être une chaîne de caractères.',
        'name.max' => 'Le nom ne doit pas dépasser 255 caractères.',

        // Messages pour le prénom
        'first_name.required' => 'Le prénom est obligatoire.',
        'first_name.string' => 'Le prénom doit être une chaîne de caractères.',
        'first_name.max' => 'Le prénom ne doit pas dépasser 255 caractères.',

        // Messages pour l'email
        'email.required' => "L'adresse email est obligatoire.",
        'email.string' => "L'adresse email doit être une chaîne de caractères.",
        'email.email' => "L'adresse email doit être une adresse valide.",
        'email.max' => "L'adresse email ne doit pas dépasser 255 caractères.",
        'email.unique' => "Cette adresse email est déjà utilisée.",

        // Messages pour le numéro de téléphone
        'phone_number.required' => 'Le numéro de téléphone est obligatoire.',
        'phone_number.string' => 'Le numéro de téléphone doit être une chaîne de caractères.',
        'phone_number.max' => 'Le numéro de téléphone ne doit pas dépasser 30 caractères.',
        'phone_number.unique' => 'Ce numéro de téléphone est déjà utilisé.',

        // Messages pour le mot de passe
        'password.required' => 'Le mot de passe est obligatoire.',
        'password.string' => 'Le mot de passe doit être une chaîne de caractères.',
        'password.confirmed' => 'La confirmation du mot de passe ne correspond pas.',

        // Messages pour le type d'utilisateur
        'type_user_id.integer' => "L'identifiant du type d'utilisateur doit être un nombre entier.",
        'type_user_id.exists' => "Le type d'utilisateur sélectionné n'existe pas.",

        // Messages pour le nom de l'appareil
        'device_name.string' => "Le nom de l'appareil doit être une chaîne de caractères.",
        'device_name.max' => "Le nom de l'appareil ne doit pas dépasser 255 caractères.",
    ];
}

}
