<?php

namespace App\Http\Controllers;

use App\Models\Attendance;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class AttendanceController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
        try {
            $attendance=Attendance::with(["student","course"])->get();
            return response()->json($attendance,200);
} catch (\Throwable $th) {
            \Illuminate\Support\Facades\Log::error($th->getMessage());
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
            'student_id' => 'required|integer|exists:student_in_classes,id',
            'course_id'  => 'required|integer|exists:courses,id',
            'date'       => 'nullable|date',
            'status'     => 'nullable|string|in:present,absent,permission',
            'reason'     => 'nullable|string'
        ]);

        $attendance = new Attendance();
        $attendance->student_id = $request->student_id;
        $attendance->course_id  = $request->course_id;
        $attendance->date       = $request->date ?? now();      // default to current date
        $attendance->status     = $request->status ?? 'present'; // default status
        $attendance->reason     = $request->reason; // ✅ add this
        $attendance->save();

        return response()->json($attendance, 201);

} catch (\Throwable $th) {
            \Illuminate\Support\Facades\Log::error($th->getMessage());
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }
    }

    /**
     * Display the specified resource.
     */
    public function show(Attendance $attendance)
    {
        //
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Attendance $attendance)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Attendance $attendance)
    {
        $validated = $request->validate([
            'status' => 'required|in:present,absent,permission',
            'reason' => 'nullable|string|max:255',
        ]);

        try {
            $attendance->update($validated);

            return response()->json($attendance->fresh());

        } catch (\Throwable $th) {
            \Illuminate\Support\Facades\Log::error($th->getMessage());
            return response()->json([
                "message" => "Update failed: " . $th->getMessage(),
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Attendance $attendance)
    {
        //
        try {
            $attendance->delete();
            return response()->json([
                "message"=>"attendance delete successfully",
            ]);
        } catch (\Throwable $th) {
            \Illuminate\Support\Facades\Log::error($th->getMessage());
             return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }
    }
}
