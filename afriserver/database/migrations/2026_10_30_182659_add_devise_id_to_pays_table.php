<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pays', function (Blueprint $table) {
            $table->foreignId('devise_id')
                ->nullable()
                ->after('organisation_id')
                ->constrained('devises')
                ->nullOnDelete();

            // Symbole affiché côté UI (dénormalisé depuis devises.symbole si besoin)
            $table->string('currency_symbol', 10)->nullable()->after('currency_code');
        });
    }

    public function down(): void
    {
        Schema::table('pays', function (Blueprint $table) {
            $table->dropConstrainedForeignId('devise_id');
            $table->dropColumn('currency_symbol');
        });
    }
};
