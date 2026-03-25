<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Check if column exists before adding (for existing deployments)
        $columnExists = Schema::connection('mysql')->hasColumn('student_in_classes', 'course_id');

        if (!$columnExists) {
            Schema::table('student_in_classes', function (Blueprint $table) {
                $table->foreignId('course_id')->nullable()->after('address');
            });

            // Add foreign key constraint separately to avoid issues
            DB::statement('ALTER TABLE `student_in_classes` ADD CONSTRAINT `student_in_classes_course_id_foreign` FOREIGN KEY (`course_id`) REFERENCES `courses`(`id`) ON DELETE CASCADE');
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('student_in_classes', function (Blueprint $table) {
            $table->dropForeign(['course_id']);
            $table->dropColumn('course_id');
        });
    }
};
