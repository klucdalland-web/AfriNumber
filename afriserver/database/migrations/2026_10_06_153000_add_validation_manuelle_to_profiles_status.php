<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        // SQLite n'applique pas les ENUM ; RefreshDatabase recrée déjà le schéma à jour.
        if (! in_array($driver, ['mysql', 'mariadb'], true)) {
            return;
        }

        DB::statement("ALTER TABLE profiles MODIFY COLUMN status ENUM(
            'en_attente_d_upload',
            'en_cours_de_verification',
            'validation_manuelle',
            'approuve',
            'rejete'
        ) NOT NULL DEFAULT 'en_attente_d_upload'");
    }

    public function down(): void
    {
        $driver = Schema::getConnection()->getDriverName();

        if (! in_array($driver, ['mysql', 'mariadb'], true)) {
            return;
        }

        // Remet les dossiers encore en revue dans le statut générique avant de retirer l'ENUM.
        DB::table('profiles')
            ->where('status', 'validation_manuelle')
            ->update(['status' => 'en_cours_de_verification']);

        DB::statement("ALTER TABLE profiles MODIFY COLUMN status ENUM(
            'en_attente_d_upload',
            'en_cours_de_verification',
            'approuve',
            'rejete'
        ) NOT NULL DEFAULT 'en_attente_d_upload'");
    }
};
