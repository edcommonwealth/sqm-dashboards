class DisaggregationRow
  attr_reader :row, :headers

  def initialize(row:, headers:)
    @row = row
    @headers = headers
  end

  def district
    @district ||= value_from(pattern: /District/i)
  end

  def academic_year
    @academic_year ||= value_from(pattern: /Academic\s*Year/i)
  end

  def income
    @income ||= value_from(pattern: /Low\s*Income/i)
  end

  def lasid
    @lasid ||= value_from(pattern: /LASID/i)
  end

  def value_from(pattern:)
    output = nil
    matches = headers.select do |header|
      pattern.match(header)
    end.map { |item| item.delete("\n") }
    matches.each do |match|
      output ||= row[match]
    end
    output
  end
end
