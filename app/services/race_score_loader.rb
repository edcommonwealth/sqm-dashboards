class RaceScoreLoader
  def self.reset(schools: School.all, academic_years: AcademicYear.all, measures: Measure.all, races: Race.all)
    RaceScore.where(school: schools, academic_year: academic_years, measure: measures, race: races).delete_all
    scores = []
    measures.each do |measure|
      schools.each do |school|
        academic_years.each do |academic_year|
          races.each do |race|
            scores << process_score(measure:, school:, academic_year:, race:)
          end
        end
      end
    end
    RaceScore.import scores, batch_size: 1000
  end

  private

  def self.process_score(measure:, school:, academic_year:, race:)
    score = RaceScoreCalculator.new(measure:, school:, academic_year:, race:).score
    rs = RaceScore.find_by(measure:, school:, academic_year:, race:)
    rs ||= RaceScore.new(measure:, school:, academic_year:, race:)
    rs.average = score.average
    rs.meets_student_threshold = score.meets_student_threshold?
    rs
  end

  private_class_method :process_score
end
