<?php

namespace App\Http\Controllers;

use App\Models\Student_in_class;
use Illuminate\Auth\Events\Validated;
use Illuminate\Http\Request;

class StudentInClassController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
        try {
            $student = Student_in_class::with('courses')->get();
            return response()->json($student,200);
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
    try {
        $request->validate([
            "name_student"=>"required|string|max:255",
            "gender"=>"required|string",
            "phone"=>"required|string",
            "parent"=>"required|string",
            "address"=>"required|string",
            "course_id"=>"required"
        ]);

        $student = new Student_in_class();
        $student->name_student = $request->name_student;
        $student->gender = $request->gender;
        $student->phone = $request->phone;
        $student->parent = $request->parent;
        $student->address = $request->address;
        $student->course_id = $request->course_id;
        $student->save();

        // Attach course + create attendance record
        $student->courses()->attach($request->course_id, [
            'date' => now(),
            'status' => 'present',
        ]);

        return response()->json($student, 201);

    } catch (\Throwable $th) {
        return response()->json([
            "message"=>$th->getMessage(),
        ], 500);
    }
}

    /**
     * Display the specified resource.
     */
    public function show(Student_in_class $student_in_class)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Student_in_class $student_in_class)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Student_in_class $student_in_class)
    {
        //
        try {
            $validate=$request->validate([
                "name_student"=>"required|string|max:255",
                "gender"=>"required|string",
                "phone"=>"required|string",
                "parent"=>"required|string",
                "address"=>"required|string",
            ]);

            $student_in_class->update($validate);

            return response()->json([
                "message"=>"Student update succussfuly",
                "data"=>$student_in_class,
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
    public function destroy(Student_in_class $student_in_class)
    {
        //
        try {
            $student_in_class->delete();
            return response()->json([
                "message"=>"Student delete successfully"
            ]);
        } catch (\Throwable $th) {
            //throw $th;
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }

    }
}
