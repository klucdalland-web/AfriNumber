<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notification_campaign_device', function (Blueprint $table) {
            $table->id();
            $table->foreignId('notification_campaign_id')->constrained('notification_campaigns')->cascadeOnDelete();
            $table->foreignId('device_id')->constrained('devices')->cascadeOnDelete();
            $table->unique(['notification_campaign_id', 'device_id'], 'campaign_device_unique');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notification_campaign_device');
    }
};
