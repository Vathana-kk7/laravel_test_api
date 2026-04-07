<?php

use App\Http\Controllers\AttendanceController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\CourseController;
use App\Http\Controllers\StudentController;
use App\Http\Controllers\StudentInClassController;
use Illuminate\Support\Facades\Route;

//forgot password and reset password
// ============================
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);
// register
Route::post("/register",[AuthController::class,"register"]);
Route::post("/login",[AuthController::class,"login"]);

Route::middleware(['auth:sanctum' , 'role'])->group(function(){
    Route::get("/student",[StudentController::class,'index']);
});

// Course
Route::get("/course",[CourseController::class,"index"]);
Route::post("/course",[CourseController::class,"store"]);

//Course update and delete
Route::put("/course/{course}",[CourseController::class,"update"]);
Route::delete("/course/{course}",[CourseController::class,"destroy"]);

// student_in_class
Route::get("/student",[StudentInClassController::class,"index"]);
Route::post("/student",[StudentInClassController::class,"store"]);

// Update student and delete
Route::put("/student/{student_in_class}",[StudentInClassController::class,"update"]);
Route::delete("/student/{student_in_class}",[StudentInClassController::class,"destroy"]);

//Attendance
Route::get("/attendance",[AttendanceController::class,"index"]);
Route::post("/attendance",[AttendanceController::class,"store"]);
//attendance update in addition delete
Route::put("/attendance/{attendance}",[AttendanceController::class,"update"]);
Route::patch("/attendance/{attendance}",[AttendanceController::class,"update"]);
Route::delete("/attendance/{attendance}",[AttendanceController::class,"destroy"]);
