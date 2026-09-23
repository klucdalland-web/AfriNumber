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
        Schema::create('piece_identites', function (Blueprint $table) {
            $table->id();
            $table->foreignId('type_piece_identite_id')->constrained();
            $table->string('numero', 100);
            $table->date('date_delivrance')->nullable();
            $table->string('lieu_delivrance', 200)->nullable();
            $table->enum('statut_piece', [
                'en_attente',
                'active',
                'refusee',
            ])->default('en_attente');
            $table->string('motif_refus', 500)->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('piece_identites');
    }
};
