<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Storage;
use Throwable;

class Profile extends Model
{
    use HasUuids;

    public const STATUS_EN_ATTENTE_D_UPLOAD = 'en_attente_d_upload';

    public const STATUS_EN_COURS_DE_VERIFICATION = 'en_cours_de_verification';

    public const STATUS_VALIDATION_MANUELLE = 'validation_manuelle';

    public const STATUS_APPROUVE = 'approuve';

    public const STATUS_REJETE = 'rejete';

    /**
     * @var list<string>
     */
    public const STATUSES = [
        self::STATUS_EN_ATTENTE_D_UPLOAD,
        self::STATUS_EN_COURS_DE_VERIFICATION,
        self::STATUS_VALIDATION_MANUELLE,
        self::STATUS_APPROUVE,
        self::STATUS_REJETE,
    ];

    /**
     * @var array<int, string>
     */
    protected $fillable = [
        'user_id',
        'status',
        'document_url',
        'documents',
        'rejection_reason',
    ];

    /**
     * @var array<string, string>
     */
    protected $casts = [
        'documents' => 'array',
    ];

    protected $keyType = 'string';

    public $incrementing = false;

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function isAwaitingManualReview(): bool
    {
        return $this->status === self::STATUS_VALIDATION_MANUELLE;
    }

    public function blocksNewVerification(): bool
    {
        return in_array($this->status, [
            self::STATUS_EN_COURS_DE_VERIFICATION,
            self::STATUS_VALIDATION_MANUELLE,
            self::STATUS_APPROUVE,
        ], true);
    }

    /**
     * URL temporaire Storj pour un document KYC (champ photopath / pieceavantpath / piecearrierepath).
     */
    public function temporaryDocumentUrl(string $champ, int $minutes = 10): ?string
    {
        $path = collect($this->documents ?? [])
            ->firstWhere('champ', $champ)['path'] ?? null;

        if (! is_string($path) || $path === '') {
            return null;
        }

        try {
            return Storage::disk('storj')->temporaryUrl($path, now()->addMinutes($minutes));
        } catch (Throwable $e) {
            Log::warning('Impossible de générer l\'URL temporaire KYC', [
                'profile_id' => $this->id,
                'champ' => $champ,
                'error' => $e->getMessage(),
            ]);

            return null;
        }
    }

    /**
     * Supprime les fichiers Storj et efface la colonne documents.
     * L'échec de suppression est journalisé sans faire échouer le verdict métier.
     */
    public function clearStoredDocuments(): void
    {
        $paths = collect($this->documents ?? [])->pluck('path')->filter()->values()->all();

        if ($paths === []) {
            return;
        }

        try {
            if (Storage::disk('storj')->delete($paths)) {
                $this->documents = null;
                $this->save();
            } else {
                Log::error('Suppression des documents échouée pour le profil '.$this->id);
            }
        } catch (Throwable $e) {
            Log::error('Erreur lors de la suppression des documents du profil '.$this->id.' : '.$e->getMessage());
        }
    }
}
