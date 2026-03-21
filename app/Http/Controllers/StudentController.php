<?php

namespace App\Http\Controllers;
use App\Models\User;

class StudentController extends Controller
{
    //
    public function index()
    {
        try {
            $student=User::all();
            return response()->json($student,200);
        } catch (\Throwable $th) {
            //throw $th;
            return response()->json([
                "message"=>$th->getMessage(),
            ],500);
        }
    }
}
