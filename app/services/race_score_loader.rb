class RaceScoreLoader
  def self.reset(schools: School.all, academic_years: AcademicYear.all, measures: Measure.all, races: Race.all)
    RaceScore.where(school: schools, academic_year: academic_years, measure: measures, race: races).delete_all
    measures.each do |measure|
      schools.each do |school|
        loadable_race_scores = []
        loadable_race_scores = academic_years.map do |academic_year|
          races.map do |race|
            process_score(measure:, school:, academic_year:, race:)
          end
        end
        RaceScore.import(loadable_race_scores.flatten.compact, batch_size: 1_000, on_duplicate_key_update: :all)
        @grouped_responses = nil
        @total_responses = nil
        @response_rate = nil
        @sufficient_responses = nil
      end
    end
  end

  private

  def self.process_score(measure:, school:, academic_year:, race:)
    score = race_score(measure:, school:, academic_year:, race:)
    { measure_id: measure.id, school_id: school.id, academic_year_id: academic_year.id, race_id: race.id, average: score.average,
      meets_student_threshold: score.meets_student_threshold? }
  end

  def self.race_score(measure:, school:, academic_year:, race:)
    rate = response_rate(school:, academic_year:, measure:)
    return Score.new(0, false, false, false) unless rate.meets_student_threshold

    survey_items = measure.student_survey_items

    students = StudentRace.where(race:).pluck(:student_id).uniq
    averages = grouped_responses(school:, academic_year:, survey_items:, students:)
    meets_student_threshold = sufficient_responses(school:, academic_year:, students:)
    scorify(responses: averages, meets_student_threshold:, measure:)
  end

  def self.grouped_responses(school:, academic_year:, survey_items:, students:)
    @grouped_responses ||= Hash.new do |memo, (school, academic_year, survey_items, students)|
      memo[[school, academic_year, survey_items, students]] = SurveyItemResponse.where(school:,
                                                                                       academic_year:,
                                                                                       student: students,
                                                                                       survey_item: survey_items)
                                                                                .group(:survey_item_id)
                                                                                .average(:likert_score)
    end

    @grouped_responses[[school, academic_year, survey_items, students]]
  end

  def self.total_responses(school:, academic_year:, students:, survey_items:)
    @total_responses ||= Hash.new do
      memo[[school, academic_year, students, survey_items]] = SurveyItemResponse.where(school:,
                                                                                       academic_year:,
                                                                                       student: students,
                                                                                       survey_item: survey_items).count
    end
    @total_responses[[school, academic_year, students, survey_items]]
  end

  def self.response_rate(school:, academic_year:, measure:)
    subcategory = measure.subcategory
    @response_rate ||= Hash.new do |memo, (school, academic_year, subcategory)|
      memo[[school, academic_year, subcategory]] =
        ResponseRate.find_by(subcategory:, school:, academic_year:)
    end

    @response_rate[[school, academic_year, subcategory]]
  end

  def self.scorify(responses:, meets_student_threshold:, measure:)
    averages = bubble_up_averages(responses:, measure:)
    average = averages.average

    average = 0 unless meets_student_threshold

    Score.new(average, false, meets_student_threshold, false)
  end

  def self.sufficient_responses(school:, academic_year:, students:)
    @sufficient_responses ||= Hash.new do |memo, (school, academic_year, students)|
      number_of_students_for_a_racial_group = SurveyItemResponse.where(school:, academic_year:,
                                                                       student: students).map(&:student).uniq.count
      memo[[school, academic_year, students]] = number_of_students_for_a_racial_group >= 10
    end
    @sufficient_responses[[school, academic_year, students]]
  end

  def self.bubble_up_averages(responses:, measure:)
    measure.student_scales.map do |scale|
      scale.survey_items.map do |survey_item|
        responses[survey_item.id]
      end.remove_blanks.average
    end.remove_blanks
  end

  private_class_method :process_score
  private_class_method :race_score
  private_class_method :grouped_responses
  private_class_method :total_responses
  private_class_method :response_rate
  private_class_method :scorify
  private_class_method :sufficient_responses
  private_class_method :bubble_up_averages
end
