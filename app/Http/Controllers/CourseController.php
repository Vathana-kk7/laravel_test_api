<?php

namespace App\Http\Controllers;

use App\Models\Course;
use Illuminate\Http\Request;

class CourseController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
        try {
            $course=Course::all();
            return response()->json($course,200);
        } catch (\Throwable $th) {
            //throw $th;
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }

    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        //
        try {

            $request->validate([
                "name_course"=>'required|string|max:255',
                "name_teacher"=>'required|string|max:255',
                "time_course"=>'required|string',
            ]);

            $course=new Course();
            $course->name_course=$request->name_course;
            $course->name_teacher=$request->name_teacher;
            $course->time_course=$request->time_course;
            $course->save();
            return response()->json($course,201);

        } catch (\Throwable $th) {
            //throw $th;
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(Course $course)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Course $course)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Course $course)
    {
        //
        try {
            $validate=$request->validate([
                "name_course"=>'required|string|max:255',
                "name_teacher"=>'required|string|max:255',
                "time_course"=>'required|string',
            ]);
            $course->update($validate);
            return response()->json([
                "message"=>"Course update successfully",
                "data"=>$course,
            ]);

        } catch (\Throwable $th) {
            //throw $th;
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Course $course)
    {
        //
        try {
            $course->delete();
            return response()->json([
                "message"=>"Course delete succesfully",
            ]);
        } catch (\Throwable $th) {
            //throw $th;
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }
    }
}
