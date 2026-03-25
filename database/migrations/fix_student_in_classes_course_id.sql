-- SQL Fix: Add missing course_id column to student_in_classes table
-- Run this on the remote Render.com MySQL database to fix the schema mismatch

-- Step 1: Check if column exists first (safety check)
-- SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
-- WHERE TABLE_SCHEMA = DATABASE()
-- AND TABLE_NAME = 'student_in_classes'
-- AND COLUMN_NAME = 'course_id';

-- Step 2: Add the course_id column if it doesn't exist
ALTER TABLE `student_in_classes`
ADD COLUMN `course_id` BIGINT UNSIGNED NULL AFTER `address`;

-- Step 3: Add foreign key constraint
ALTER TABLE `student_in_classes`
ADD CONSTRAINT `student_in_classes_course_id_foreign`
FOREIGN KEY (`course_id`)
REFERENCES `courses`(`id`)
ON DELETE CASCADE;

-- Step 4: Set any existing records to have a default course_id if needed
-- UPDATE `student_in_classes` SET `course_id` = 1 WHERE `course_id` IS NULL;

-- Verification query
-- SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
-- WHERE TABLE_NAME = 'student_in_classes'
-- AND CONSTRAINT_NAME LIKE '%course_id%';
