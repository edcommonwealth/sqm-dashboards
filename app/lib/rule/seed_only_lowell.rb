module Rule
  class SeedOnlyLowell
    attr_reader :row

    def initialize(row:)
      @row = row
    end

    def skip_row?
      district = row['District'].strip.downcase
      'lowell' != district
    end
  end
end
