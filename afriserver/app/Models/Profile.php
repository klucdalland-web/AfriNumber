<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids; // 🚀 AJOUT OBLIGATOIRE

class Profile extends Model
{
    use HasUuids; // 🚀 AJOUT OBLIGATOIRE : Génère l'UUID automatiquement

    /**
     * Les attributs qui peuvent être assignés en masse.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'status',
        'document_url',
    ];

    // 🔒 Indique que la clé primaire est une chaîne de caractères non incrémentale
    protected $keyType = 'string';
    public $incrementing = false;

    /**
     * Récupère l'utilisateur auquel appartient ce profil de vérification.
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}
