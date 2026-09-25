<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('observability_logs', function (Blueprint $table) {
            $table->json('session')->nullable()->after('data_after');
        });
    }

    public function down(): void
    {
        Schema::table('observability_logs', function (Blueprint $table) {
            $table->dropColumn('session');
        });
    }
};
