<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('observability_logs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->nullable()->constrained()->nullOnDelete();
            $table->foreignId('device_id')->nullable()->constrained('devices')->nullOnDelete();

            $table->string('device_identifier', 255)->nullable()->index();
            $table->string('category', 50)->index();
            $table->string('action', 100)->index();
            $table->string('level', 20)->default('info')->index();
            $table->string('message', 500)->nullable();

            $table->string('method', 10)->nullable();
            $table->string('path', 500)->nullable();
            $table->string('route_name', 150)->nullable();
            $table->unsignedSmallInteger('status_code')->nullable()->index();

            $table->string('ip_address', 45)->nullable()->index();
            $table->text('user_agent')->nullable();

            $table->json('request_payload')->nullable();
            $table->json('context')->nullable();

            $table->unsignedInteger('duration_ms')->nullable();

            $table->timestamp('created_at')->useCurrent()->index();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('observability_logs');
    }
};
