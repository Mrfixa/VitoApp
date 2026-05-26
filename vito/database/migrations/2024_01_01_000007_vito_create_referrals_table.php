<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('vito_referrals', function (Blueprint $table) {
            $table->uuid('id')->primary();
            $table->foreignUuid('referrer_driver_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('referred_customer_id')->constrained('users')->cascadeOnDelete();
            $table->foreignUuid('qr_token_id')->nullable()->constrained('qr_tokens')->nullOnDelete();
            $table->timestamps();

            $table->unique(['referrer_driver_id', 'referred_customer_id']);
            $table->index('referrer_driver_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('vito_referrals');
    }
};
