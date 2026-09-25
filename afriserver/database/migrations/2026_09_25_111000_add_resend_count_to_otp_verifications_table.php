<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('otp_verifications')) {
            return;
        }

        Schema::table('otp_verifications', function (Blueprint $table) {
            if (! Schema::hasColumn('otp_verifications', 'resend_count')) {
                $table->unsignedTinyInteger('resend_count')->default(0)->after('attempts');
            }
        });
    }

    public function down(): void
    {
        if (! Schema::hasTable('otp_verifications')) {
            return;
        }

        Schema::table('otp_verifications', function (Blueprint $table) {
            if (Schema::hasColumn('otp_verifications', 'resend_count')) {
                $table->dropColumn('resend_count');
            }
        });
    }
};
