module Rule
  class SkipNonLowellSchools
    attr_reader :row

    def initialize(row:)
      @row = row
    end

    def skip_row?
      return true if row.school.nil?
      return true if row.school.district.nil?

      row.school.district.name != 'Lowell'
    end
  end
end
