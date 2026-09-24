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
        Schema::create('session_users', function (Blueprint $table) {
            $table->foreignId('device_id')->primary()->constrained();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();

            $table->text('user_agent')->nullable();
            $table->string('ip_address', 45)->nullable();
            $table->string('country')->nullable();

            $table->string('city')->nullable();
            $table->string('region')->nullable();
            $table->string('timezone')->nullable();
            $table->decimal('latitude', 10, 8)->nullable();
            $table->string('internet_provider')->nullable();
            $table->string('network_type')->nullable();

            $table->boolean('is_active')->default(true);

            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('session_users');
    }
};
