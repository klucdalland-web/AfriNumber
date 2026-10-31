<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('frais_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('type_transaction_id')->constrained('type_transactions');
            $table->foreignId('pays_id')->nullable()->constrained('pays'); // null = frais par défaut
            $table->decimal('montant_fixe', 20, 8)->default(0);     // en USD
            $table->decimal('taux_pourcentage', 8, 4)->default(0);  // 1.5000 = 1,5 %
            $table->decimal('montant_min', 20, 8)->nullable();
            $table->decimal('montant_max', 20, 8)->nullable();
            $table->enum('statut', ['ACTIF', 'INACTIF'])->default('ACTIF');
            $table->timestamps();

            $table->unique(['type_transaction_id', 'pays_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('frais_transactions');
    }
};
