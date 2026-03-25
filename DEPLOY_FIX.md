# Database Fix Deployment Guide

## Problem
The remote MySQL database on Render.com is missing the `course_id` column in the `student_in_classes` table, causing a 500 error when creating students.

## Solution
This fix includes a new migration that safely adds the column if it doesn't exist.

## Steps to Deploy

### Option 1: Redeploy on Render.com (Recommended)
1. Commit the new migration file `2026_03_25_add_course_id_to_student_in_classes.php`
2. Push to your Git repository
3. Render.com will automatically rebuild and run migrations via `start.sh`

### Option 2: Manual SQL Fix (Quick Fix)
Run the SQL script on your Render.com MySQL database:

```sql
ALTER TABLE `student_in_classes` 
ADD COLUMN `course_id` BIGINT UNSIGNED NULL AFTER `address`;

ALTER TABLE `student_in_classes` 
ADD CONSTRAINT `student_in_classes_course_id_foreign` 
FOREIGN KEY (`course_id`) 
REFERENCES `courses`(`id`) 
ON DELETE CASCADE;
```

To access Render.com MySQL:
1. Go to your Render Dashboard
2. Select your MySQL database
3. Click "Connect" → "Shell Access"
4. Run the SQL commands above

### Option 3: Force Migrate via Render Shell
1. Go to your Web Service on Render.com
2. Click "Shell" to open a terminal
3. Run: `php artisan migrate --force`

## Files Created
- `database/migrations/2026_03_25_add_course_id_to_student_in_classes.php` - Safe migration that checks if column exists
- `database/migrations/fix_student_in_classes_course_id.sql` - Raw SQL for manual execution

## Verification
After deployment, test the student creation endpoint:
```bash
curl -X POST https://laravel-test-api-qpy0.onrender.com/api/student \
  -H "Content-Type: application/json" \
  -d '{"name_student":"Test","gender":"Male","phone":"123","parent":"Parent","address":"Address","course_id":1}'
```

Expected: 201 Created response
