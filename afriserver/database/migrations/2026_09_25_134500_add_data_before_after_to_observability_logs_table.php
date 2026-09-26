<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('observability_logs', function (Blueprint $table) {
            $table->json('data_before')->nullable()->after('context');
            $table->json('data_after')->nullable()->after('data_before');
        });
    }

    public function down(): void
    {
        Schema::table('observability_logs', function (Blueprint $table) {
            $table->dropColumn(['data_before', 'data_after']);
        });
    }
};
