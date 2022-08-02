# frozen_string_literal: true

module AnalysisGraph
  class StudentsAndTeachers
    def to_s
      'Students & Teachers'
    end

    def value
      'students-and-teachers'
    end

    def columns
      [StudentGroupedBarColumnPresenter, TeacherGroupedBarColumnPresenter, GroupedBarColumnPresenter]
    end
  end
end
