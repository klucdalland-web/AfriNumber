<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('password_reset_codes', function (Blueprint $table) {
            if (! Schema::hasColumn('password_reset_codes', 'attempts')) {
                $table->unsignedTinyInteger('attempts')->default(0)->after('code');
            }

            if (! Schema::hasColumn('password_reset_codes', 'resend_count')) {
                $table->unsignedTinyInteger('resend_count')->default(0)->after('attempts');
            }

            if (! Schema::hasColumn('password_reset_codes', 'locked_until')) {
                $table->timestamp('locked_until')->nullable()->after('resend_count');
            }
        });
    }

    public function down(): void
    {
        Schema::table('password_reset_codes', function (Blueprint $table) {
            $columns = array_filter(['attempts', 'resend_count', 'locked_until'], function (string $column): bool {
                return Schema::hasColumn('password_reset_codes', $column);
            });

            if ($columns !== []) {
                $table->dropColumn($columns);
            }
        });
    }
};
