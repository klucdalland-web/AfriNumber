<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('otp_verifications', function (Blueprint $table) {
            $table->id();
            $table->string('email')->nullable();
            $table->string('phone_number')->nullable();
            $table->string('purpose'); // 'register' ou 'login'
            $table->string('code'); // haché
            $table->text('payload')->nullable();
            $table->unsignedTinyInteger('attempts')->default(0);
            $table->timestamp('locked_until')->nullable();
            $table->timestamp('expires_at');
            $table->timestamps();

            $table->unique(['email', 'phone_number', 'purpose']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('otp_verifications');
    }
};