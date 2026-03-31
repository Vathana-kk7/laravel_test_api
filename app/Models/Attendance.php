<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Attendance extends Model
{
protected $fillable = ['student_id','course_id','date','status','reason'];

    public function student(){
        return $this->belongsTo(Student_in_class::class,'student_id');
    }

    public function course(){
        return $this->belongsTo(Course::class,'course_id');
    }
}
