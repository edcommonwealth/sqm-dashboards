module AnalysisGraph
  class StudentsByGroup
    def to_s
      'Students by Group'
    end

    def value
      'students-by-group'
    end

    def columns
      [StudentGroupedBarColumnPresenter]
    end
  end
end
