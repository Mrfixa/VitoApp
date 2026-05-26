<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('mart_orders', function (Blueprint $table) {
            $table->text('delivery_signature')->nullable()->after('delivery_photo');
        });
    }

    public function down(): void
    {
        Schema::table('mart_orders', function (Blueprint $table) {
            $table->dropColumn('delivery_signature');
        });
    }
};
