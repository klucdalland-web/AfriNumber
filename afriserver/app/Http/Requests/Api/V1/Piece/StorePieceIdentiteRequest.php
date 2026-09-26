<?php

namespace App\Http\Requests\Api\V1\Piece;

use Illuminate\Foundation\Http\FormRequest;

class StorePieceIdentiteRequest extends FormRequest
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
            'type_piece_identite_id' => ['required', 'integer', 'exists:type_piece_identites,id'],
            'numero' => ['required', 'string', 'max:100'],
            'date_delivrance' => ['nullable', 'date', 'before_or_equal:today'],
            'lieu_delivrance' => ['nullable', 'string', 'max:200'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'type_piece_identite_id.required' => 'Le type de pièce est obligatoire.',
            'type_piece_identite_id.integer' => 'Le type de pièce doit être un identifiant numérique.',
            'type_piece_identite_id.exists' => 'Le type de pièce sélectionné est invalide.',
            'numero.required' => 'Le numéro de la pièce est obligatoire.',
            'numero.max' => 'Le numéro ne doit pas dépasser 100 caractères.',
            'date_delivrance.date' => 'La date de délivrance est invalide.',
            'date_delivrance.before_or_equal' => 'La date de délivrance ne peut pas être dans le futur.',
            'lieu_delivrance.max' => 'Le lieu de délivrance ne doit pas dépasser 200 caractères.',
        ];
    }
}
