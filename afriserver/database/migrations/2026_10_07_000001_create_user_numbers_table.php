<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_numbers', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->foreignId('plan_id')->nullable()->constrained('plans')->onDelete('set null');
            $table->string('phone_number');
            $table->string('country_code', 2);
            $table->string('provider'); // e.g., 'verifiedcore', 'zavu'
            $table->string('provider_number_id')->nullable(); // ID from the external API
            $table->string('status')->default('active'); // active, expired, suspended
            $table->decimal('price', 8, 2);
            $table->timestamp('purchased_at')->useCurrent();
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_numbers');
    }
};
