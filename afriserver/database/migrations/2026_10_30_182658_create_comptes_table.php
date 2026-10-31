<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('comptes', function (Blueprint $table) {
            $table->id();
            $table->string('numero_compte', 30)->unique();
            $table->decimal('solde', 20, 8)->default(0);
            $table->enum('statut', ['ACTIF', 'SUSPENDU', 'FERME'])->default('ACTIF');
            $table->foreignId('user_id')->unique()->constrained()->cascadeOnDelete();
            $table->timestamps();

            $table->index('statut');
        });

        // CHECK solde >= 0 (MySQL 8.0.16+ / Postgres ; ignoré ou soft sur SQLite selon driver)
        if (Schema::getConnection()->getDriverName() !== 'sqlite') {
            Schema::getConnection()->statement(
                'ALTER TABLE comptes ADD CONSTRAINT comptes_solde_non_negatif CHECK (solde >= 0)'
            );
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('comptes');
    }
};
