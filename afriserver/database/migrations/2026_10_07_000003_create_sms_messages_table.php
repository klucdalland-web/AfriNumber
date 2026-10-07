<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('sms_messages', function (Blueprint $table) {
            $table->uuid('id')->primary();
            // Correction : On utilise uuid() au lieu de foreignId() pour correspondre à la table user_numbers
            $table->foreignUuid('user_number_id')->constrained('user_numbers')->onDelete('cascade');
            $table->string('sender');
            $table->text('content');
            $table->timestamp('received_at')->useCurrent();
            $table->boolean('is_read')->default(false);
            $table->timestamps();

            $table->index('user_number_id');
            $table->index('received_at');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('sms_messages');
    }
};
