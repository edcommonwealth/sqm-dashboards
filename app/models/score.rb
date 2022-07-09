class Score < Struct.new(:average, :meets_teacher_threshold?, :meets_student_threshold?, :meets_admin_data_threshold?)
  NIL_SCORE = Score.new(nil, false, false, false)
end
