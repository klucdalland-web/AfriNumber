<?php

namespace App\Http\Requests\Api\V1\Piece;

use Illuminate\Foundation\Http\FormRequest;

class StoreFichierPieceRequest extends FormRequest
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
            'fichiers' => ['required', 'array', 'min:1', 'max:5'],
            'fichiers.*' => [
                'required',
                'file',
                'mimes:jpg,jpeg,png,webp,pdf,heic,heif',
                'max:10240', // 10 Mo
            ],
        ];
    }

    /**
     * @return array<string, string>
     */
    public function messages(): array
    {
        return [
            'fichiers.required' => 'Au moins un fichier est requis.',
            'fichiers.array' => 'Les fichiers doivent être envoyés sous forme de liste.',
            'fichiers.min' => 'Au moins un fichier est requis.',
            'fichiers.max' => 'Vous ne pouvez pas envoyer plus de 5 fichiers.',
            'fichiers.*.required' => 'Chaque fichier est obligatoire.',
            'fichiers.*.file' => 'Chaque élément doit être un fichier valide.',
            'fichiers.*.mimes' => 'Formats acceptés : jpg, jpeg, png, webp, pdf, heic, heif.',
            'fichiers.*.max' => 'Chaque fichier ne doit pas dépasser 10 Mo.',
        ];
    }
}
