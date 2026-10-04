<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TypeTransaction extends Model
{
    public const CODE_SUBSCRIPTION = 'subscription';

    public const CODE_RENEWAL = 'renewal';

    public const CODE_UPGRADE = 'upgrade';

    public const CODE_NUMBER = 'number';

    public const CODE_FORFAIT = 'forfait';

    /**
     * @var list<string>
     */
    protected $fillable = [
        'label',
        'code',
        'description',
        'actif',
        'sort_order',
    ];

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'actif' => 'boolean',
            'sort_order' => 'integer',
        ];
    }

    /**
     * @return HasMany<Transaction, $this>
     */
    public function transactions(): HasMany
    {
        return $this->hasMany(Transaction::class);
    }
}
