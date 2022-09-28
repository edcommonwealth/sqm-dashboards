class RaceScoreLoader
  def self.reset(schools: School.all, academic_years: AcademicYear.all, measures: Measure.all, races: Race.all, fast_processing: true)
    RaceScore.where(school: schools, academic_year: academic_years, measure: measures, race: races).delete_all
    measures.each do |measure|
      if fast_processing
        large_memory_use(measure:, schools:, academic_years:, races:)
      else
        slow_loading_time(measure:, schools:, academic_years:, races:)
      end
    end
  end

  private

  def self.large_memory_use(measure:, schools:, academic_years:, races:)
    loadable_race_scores = schools.map do |school|
      academic_years.map do |academic_year|
        races.map do |race|
          process_score(measure:, school:, academic_year:, race:)
        end
      end
    end
    RaceScore.import(loadable_race_scores.flatten.compact, batch_size: 1_000, on_duplicate_key_update: :all)
  end

  def self.slow_loading_time(measure:, schools:, academic_years:, races:)
    schools.each do |school|
      loadable_race_scores = academic_years.map do |academic_year|
        races.map do |race|
          process_score(measure:, school:, academic_year:, race:)
        end
      end
      RaceScore.import(loadable_race_scores.flatten.compact, batch_size: 1_000, on_duplicate_key_update: :all)
      @grouped_responses = nil
      @response_rate = nil
      @sufficient_responses = nil
    end
  end

  def self.process_score(measure:, school:, academic_year:, race:)
    score = race_score(measure:, school:, academic_year:, race:)
    { measure_id: measure.id, school_id: school.id, academic_year_id: academic_year.id, race_id: race.id, average: score.average,
      meets_student_threshold: score.meets_student_threshold? }
  end

  def self.race_score(measure:, school:, academic_year:, race:)
    rate = response_rate(school:, academic_year:, measure:)
    return Score.new(average: 0, meets_teacher_threshold: false, meets_student_threshold: false, meets_admin_data_threshold: false) unless rate.meets_student_threshold

    survey_items = measure.student_survey_items

    averages = grouped_responses(school:, academic_year:, survey_items:, race:)
    meets_student_threshold = sufficient_responses(school:, academic_year:, race:)
    scorify(responses: averages, meets_student_threshold:, measure:)
  end

  def self.grouped_responses(school:, academic_year:, survey_items:, race:)
    @grouped_responses ||= Hash.new do |memo, (school, academic_year, survey_items, race)|
      memo[[school, academic_year, survey_items, race]] =
        SurveyItemResponse.joins('JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id').where(
          school:, academic_year:
        ).where('student_races.race_id': race.id).group(:survey_item_id).average(:likert_score)
    end

    @grouped_responses[[school, academic_year, survey_items, race]]
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

    Score.new(average:, meets_teacher_threshold: false, meets_student_threshold:, meets_admin_data_threshold: false)
  end

  def self.sufficient_responses(school:, academic_year:, race:)
    @sufficient_responses ||= Hash.new do |memo, (school, academic_year, race)|
      number_of_students_for_a_racial_group = SurveyItemResponse.joins('JOIN student_races on survey_item_responses.student_id = student_races.student_id JOIN students on students.id = student_races.student_id').where(
        school:, academic_year:
      ).where("student_races.race_id": race.id).distinct.pluck(:student_id).count
      memo[[school, academic_year, race]] = number_of_students_for_a_racial_group >= 10
    end
    @sufficient_responses[[school, academic_year, race]]
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
  private_class_method :response_rate
  private_class_method :scorify
  private_class_method :sufficient_responses
  private_class_method :bubble_up_averages
end
