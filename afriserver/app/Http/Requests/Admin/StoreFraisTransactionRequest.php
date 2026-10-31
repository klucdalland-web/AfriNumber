<?php

namespace App\Http\Requests\Admin;

use App\Http\Requests\Admin\Concerns\ValidatesFraisTransaction;
use Illuminate\Foundation\Http\FormRequest;

class StoreFraisTransactionRequest extends FormRequest
{
    use ValidatesFraisTransaction;
}
