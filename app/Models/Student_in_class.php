<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Student_in_class extends Model
{
    protected $fillable = ['name_student','gender','phone','parent','address','course_id'];

    public function courses(){
        return $this->belongsToMany(
            Course::class,
            'attendances',
            'student_id',
            'course_id'
        )->withPivot(['date','status']);
    }
}
