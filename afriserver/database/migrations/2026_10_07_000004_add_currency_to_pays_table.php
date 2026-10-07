<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pays', function (Blueprint $table) {
            $table->string('currency_code', 3)->nullable()->after('code');
            $table->decimal('exchange_rate', 15, 4)->default(1.0000)->after('currency_code');
        });
    }

    public function down(): void
    {
        Schema::table('pays', function (Blueprint $table) {
            $table->dropColumn('currency_code');
            $table->dropColumn('exchange_rate');
        });
    }
};
