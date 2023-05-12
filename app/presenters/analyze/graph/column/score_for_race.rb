module Analyze
  module Graph
    module Column
      module ScoreForRace
        def score(year_index)
          s = ::RaceScore.find_by(measure:, school:, academic_year: academic_years[year_index], race:)
          average = s.average.round(2) unless s.nil?
          average ||= 0
          meets_student_threshold = s.meets_student_threshold? unless s.nil?
          meets_student_threshold ||= false
          Score.new(average:,
                    meets_teacher_threshold: false,
                    meets_student_threshold:,
                    meets_admin_data_threshold: false)
        end
      end
    end
  end
end
