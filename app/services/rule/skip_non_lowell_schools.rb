module Rule
  class SkipNonLowellSchools
    attr_reader :row

    def initialize(row:)
      @row = row
    end

    def skip_row?
      row.school.district.name != 'Lowell'
    end
  end
end
