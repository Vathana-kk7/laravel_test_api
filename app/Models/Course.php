<?php

namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Course extends Model
{
    protected $fillable = ['name_course','name_teacher','time_course'];

    public function students(){
        return $this->belongsToMany(
            Student_in_class::class,
            'attendances',
            'course_id',
            'student_id'
        )->withPivot(['date','status']);
    }
}
