<?php

namespace App\Http\Requests\Api\V1\Piece;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdatePieceIdentiteRequest extends FormRequest
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
            'type_piece_identite_id' => ['sometimes', 'integer', 'exists:type_piece_identites,id'],
            'numero' => ['sometimes', 'string', 'max:100'],
            'date_delivrance' => ['nullable', 'date', 'before_or_equal:today'],
            'lieu_delivrance' => ['nullable', 'string', 'max:200'],
            'statut_piece' => ['sometimes', 'string', Rule::in(['en_attente', 'active', 'refusee'])],
            'motif_refus' => ['nullable', 'string', 'max:500', 'required_if:statut_piece,refusee'],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'type_piece_identite_id.exists' => 'Le type de pièce sélectionné est invalide.',
            'numero.max' => 'Le numéro ne doit pas dépasser 100 caractères.',
            'date_delivrance.date' => 'La date de délivrance est invalide.',
            'date_delivrance.before_or_equal' => 'La date de délivrance ne peut pas être dans le futur.',
            'lieu_delivrance.max' => 'Le lieu de délivrance ne doit pas dépasser 200 caractères.',
            'statut_piece.in' => 'Le statut doit être en_attente, active ou refusee.',
            'motif_refus.required_if' => 'Le motif de refus est obligatoire lorsque la pièce est refusée.',
            'motif_refus.max' => 'Le motif de refus ne doit pas dépasser 500 caractères.',
        ];
    }
}
