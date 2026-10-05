<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_campaigns', function (Blueprint $table) {
            $table->id();
            $table->foreignId('sent_by')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('type_notification_id')->nullable()->constrained('type_notifications')->nullOnDelete();
            $table->json('channels');
            $table->string('audience_type', 30);
            $table->foreignId('organisation_id')->nullable()->constrained('organisations')->nullOnDelete();
            $table->foreignId('pays_id')->nullable()->constrained('pays')->nullOnDelete();
            $table->string('device_scope', 20)->default('all');
            $table->string('title', 255);
            $table->text('body');
            $table->string('email_subject', 255)->nullable();
            $table->timestamp('scheduled_at')->nullable()->index();
            $table->string('status', 30)->default('queued')->index();
            $table->json('stats')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_campaigns');
    }
};
