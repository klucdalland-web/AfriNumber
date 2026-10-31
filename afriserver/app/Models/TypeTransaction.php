<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class TypeTransaction extends Model
{
    public const CODE_SUBSCRIPTION = 'subscription';

    public const CODE_RENEWAL = 'renewal';

    public const CODE_UPGRADE = 'upgrade';

    public const CODE_TOPUP = 'topup';

    public const CODE_NUMBER = 'number';

    public const CODE_FORFAIT = 'forfait';

    public const CODE_TRANSFER_W2W = 'transfer_w2w';

    public const CODE_TRANSFER_W2E = 'transfer_w2e';

    public const CODE_FEE = 'fee';

    public const CODE_REFUND = 'refund';

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

    /**
     * @return HasMany<FraisTransaction, $this>
     */
    public function frais(): HasMany
    {
        return $this->hasMany(FraisTransaction::class);
    }
}
