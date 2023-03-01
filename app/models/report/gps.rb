module Report
  class Gps
    def self.to_csv
      headers = ['School', 'Pillar', 'Indicator', 'Period', 'HALS Category', 'Measures', 'Score', 'Zone']
      attributes = %w[school_name pillar indicator period category measure_ids score zone]
      pillars = generate_pillars
      CSV.generate(headers: true) do |csv|
        csv << headers
        pillars.each do |gps|
          csv << attributes.map { |attr| gps.send(attr) }
        end
      end
    end

    def self.generate_pillars
      schools = School.all
      academic_years = AcademicYear.order(range: :desc).first(2)
      periods = %w[Current Previous]
      indicator_1 = 'Teaching'
      measures_1 = [Measure.find_by_measure_id('1A-iii'), Measure.find_by_measure_id('1B-ii')]

      [].tap do |pillars|
        schools.each do |school|
          academic_years.zip(periods).each do |academic_year, period|
            pillars << Pillar.new(school:, measures: measures_1, indicator: indicator_1, period:,
                                  academic_year:)
          end
        end
      end
    end
  end
end
