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
        Schema::create('devices', function (Blueprint $table) {
            $table->id();

            $table->foreignId('user_id')->constrained();
            $table->foreignId('platform_id')->constrained();

            $table->string('name', 200);
            $table->string('type', 100)->nullable();
            $table->string('identifier', 255)->nullable();
            $table->string('os', 100)->nullable();
            $table->string('os_version', 100)->nullable();
            $table->string('model', 150)->nullable();
            $table->string('manufacturer', 150)->nullable();
            $table->boolean('actif')->default(true);
            $table->timestamp('last_used_at')->nullable();

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('devices');
    }
};
