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
        Schema::create('fichier_pieces', function (Blueprint $table) {
            $table->id();

            $table->foreignId('piece_identite_id')->constrained()->onDelete('cascade');

            $table->string('nom_fichier', 255);
            $table->string('chemin_fichier', 500);
            $table->string('type_fichier', 100)->nullable();
            $table->unsignedBigInteger('taille_fichier')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('fichier_pieces');
    }
};
