module Report
  class Pillar
    attr_reader :period, :measures, :indicator, :school, :academic_year

    def initialize(school:, period:, measures:, indicator:, academic_year:)
      @school = school
      @measures = measures
      @indicator = indicator
      @period = period
      @academic_year = academic_year
    end

    def school_name
      school.name
    end

    def pillar
      pillars[indicator.to_sym]
    end

    def score
      measures.map do |measure|
        measure.score(school:, academic_year:).average
      end.flatten.compact.average
    end

    def category
      measures.first.category.name
    end

    def measure_ids
      measures.map(&:measure_id).join(' & ')
    end

    def zone
      zones = Zones.new(watch_low_benchmark:,
                        growth_low_benchmark:,
                        approval_low_benchmark:,
                        ideal_low_benchmark:)

      zones.zone_for_score(score).type.to_s
    end

    private

    def pillars
      { "Teaching Environment": 'Operational Efficiency',
        "Safety": 'Safe and Welcoming Environment',
        "Relationships": 'Safe and Welcoming Environment',
        "Academic Orientation": 'Safe and Welcoming Environment',
        "Facilities & Personnel": 'Operational Efficiency',
        "Family-School Relationships": 'Family and Community Engagement',
        "Community Involvement & External Partners": 'Family and Community Engagement',
        "Perception of Performance": 'Academics and Student Achievement',
        "Student Commitment To Learning": 'Academics and Student Achievement',
        "Critical Thinking": 'Academics and Student Achievement',
        "College & Career Readiness": 'Academics and Student Achievement' }
    end

    def watch_low_benchmark
      measures.map do |measure|
        measure.watch_low_benchmark
      end.average
    end

    def growth_low_benchmark
      measures.map do |measure|
        measure.growth_low_benchmark
      end.average
    end

    def approval_low_benchmark
      measures.map do |measure|
        measure.approval_low_benchmark
      end.average
    end

    def ideal_low_benchmark
      measures.map do |measure|
        measure.ideal_low_benchmark
      end.average
    end
  end
end
