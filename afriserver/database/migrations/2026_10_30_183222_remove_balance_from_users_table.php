<?php

use App\Models\Compte;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        if (Schema::hasColumn('users', 'balance')) {
            // Migre le solde existant vers comptes avant de dropper la colonne
            $users = DB::table('users')->select('id', 'balance')->get();

            foreach ($users as $user) {
                $exists = DB::table('comptes')->where('user_id', $user->id)->exists();
                $solde = (float) ($user->balance ?? 0);

                if ($exists) {
                    if ($solde > 0) {
                        DB::table('comptes')
                            ->where('user_id', $user->id)
                            ->update(['solde' => $solde, 'updated_at' => now()]);
                    }

                    continue;
                }

                DB::table('comptes')->insert([
                    // en haut du fichier

// dans l'insert
                    'numero_compte' => 'AFN' . strtoupper(base_convert($user->id, 10, 36)) . strtoupper(Str::random(4)),
                    'solde' => $solde,
                    'statut' => Compte::STATUT_ACTIF,
                    'user_id' => $user->id,
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            Schema::table('users', function (Blueprint $table) {
                $table->dropColumn('balance');
            });
        }
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->decimal('balance', 12, 2)->default(0.00)->after('type_user_id');
        });

        // Remet le solde compte → users.balance
        $comptes = DB::table('comptes')->select('user_id', 'solde')->get();

        foreach ($comptes as $compte) {
            DB::table('users')
                ->where('id', $compte->user_id)
                ->update(['balance' => round((float) $compte->solde, 2)]);
        }
    }
};
