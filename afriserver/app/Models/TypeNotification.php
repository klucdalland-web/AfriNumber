<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class TypeNotification extends Model
{
    public const CODE_KYC_APPROVED = 'kyc_approved';

    public const CODE_KYC_REJECTED = 'kyc_rejected';

    public const CODE_KYC_MANUAL_REVIEW = 'kyc_manual_review';

    public const CODE_GENERAL = 'general_communication';

    public const CODE_ALERT = 'alert';

    public const CODE_SUBSCRIPTION = 'subscription';

    public const CODE_PAYMENT = 'payment';

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
}
