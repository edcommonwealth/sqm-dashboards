class RaceScoreLoader
  def self.reset(schools: School.all, academic_years: AcademicYear.all, measures: Measure.all, races: Race.all)
    measures.each do |measure|
      schools.each do |school|
        academic_years.each do |academic_year|
          races.each do |race|
            process_score(measure:, school:, academic_year:, race:)
          end
        end
      end
    end
  end

  private

  def self.process_score(measure:, school:, academic_year:, race:)
    score = RaceScoreCalculator.new(measure:, school:, academic_year:, race:).score
    rs = RaceScore.find_or_create_by(measure:, school:, academic_year:, race:)
    rs.average = score.average
    rs.meets_student_threshold = score.meets_student_threshold?
    rs.save
  end

  private_class_method :process_score
end
