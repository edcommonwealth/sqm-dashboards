class SurveyItemResponse < ActiveRecord::Base
  TEACHER_RESPONSE_THRESHOLD = 17
  STUDENT_RESPONSE_THRESHOLD = 196

  belongs_to :academic_year
  belongs_to :school
  belongs_to :survey_item

  def self.score_for_subcategory(subcategory:, school:, academic_year:)
    measures = measures_with_sufficient_data(subcategory: subcategory, school: school, academic_year: academic_year)

    return nil unless measures.size.positive?

    measures.map do |measure|
      responses_for_measure(measure: measure, school: school, academic_year: academic_year).average(:likert_score)
    end.average
  end

  def self.average_number_of_student_respondents(subcategory:, school:, academic_year:)
    response_count = subcategory.measures.map do |measure|
      next 0 unless measure.includes_student_survey_items?

      SurveyItemResponse.student_responses_for_measure(measure, school, academic_year).count
    end.sum

    survey_item_count = subcategory.measures.map do |measure|
      measure.student_survey_items.count
    end.sum
    return 0 unless survey_item_count.positive?

    response_count / survey_item_count
  end

  def self.measures_with_sufficient_data(subcategory:, school:, academic_year:)
    subcategory.measures.select do |measure|
      sufficient_data?(measure: measure, school: school, academic_year: academic_year)
    end
  end

  def self.responses_for_measure(measure:, school:, academic_year:)
    meets_teacher_threshold = teacher_sufficient_data? measure: measure, school: school, academic_year: academic_year
    meets_student_threshold = student_sufficient_data? measure: measure, school: school, academic_year: academic_year
    meets_all_thresholds = meets_teacher_threshold && meets_student_threshold

    if meets_all_thresholds
      SurveyItemResponse.for_measure(measure, school, academic_year)
    elsif meets_teacher_threshold
      SurveyItemResponse.teacher_responses_for_measure(measure, school, academic_year)
    elsif meets_student_threshold
      SurveyItemResponse.student_responses_for_measure(measure, school, academic_year)
    end
  end

  def self.score_for_measure(measure:, school:, academic_year:)
    meets_teacher_threshold = teacher_sufficient_data? measure: measure, school: school, academic_year: academic_year
    meets_student_threshold = student_sufficient_data? measure: measure, school: school, academic_year: academic_year

    survey_item_responses = responses_for_measure(measure: measure, school: school, academic_year: academic_year)

    score_for_measure = survey_item_responses.average(:likert_score) unless survey_item_responses.nil?

    Score.new(score_for_measure, meets_teacher_threshold, meets_student_threshold)
  end

  def self.sufficient_data?(measure:, school:, academic_year:)
    meets_teacher_threshold = teacher_sufficient_data? measure: measure, school: school, academic_year: academic_year
    meets_student_threshold = student_sufficient_data? measure: measure, school: school, academic_year: academic_year
    meets_teacher_threshold || meets_student_threshold
  end

  scope :for_measure, lambda { |measure, school, academic_year|
                        joins(:survey_item)
                          .where('survey_items.measure': measure)
                          .where(school: school, academic_year: academic_year)
                      }
  scope :for_measures, lambda { |measures, school, academic_year|
                         joins(:survey_item)
                           .where('survey_items.measure': measures)
                           .where(school: school, academic_year: academic_year)
                       }

  scope :teacher_responses_for_measure, lambda { |measure, school, academic_year|
                                          for_measure(measure, school, academic_year)
                                            .where("survey_items.survey_item_id LIKE 't-%'")
                                        }
  scope :student_responses_for_measure, lambda { |measure, school, academic_year|
                                          for_measure(measure, school, academic_year)
                                            .where("survey_items.survey_item_id LIKE 's-%'")
                                        }

  def self.student_sufficient_data?(measure:, school:, academic_year:)
    if measure.includes_student_survey_items?
      student_survey_item_responses = SurveyItemResponse.student_responses_for_measure(measure, school, academic_year)
      average_number_of_survey_item_responses = student_survey_item_responses.count / measure.student_survey_items.count

      meets_student_threshold = average_number_of_survey_item_responses >= STUDENT_RESPONSE_THRESHOLD
    end
    !!meets_student_threshold
  end

  def self.teacher_sufficient_data?(measure:, school:, academic_year:)
    if measure.includes_teacher_survey_items?
      teacher_survey_item_responses = SurveyItemResponse.teacher_responses_for_measure(measure, school, academic_year)
      average_number_of_survey_item_responses = teacher_survey_item_responses.count / measure.teacher_survey_items.count

      meets_teacher_threshold = average_number_of_survey_item_responses >= TEACHER_RESPONSE_THRESHOLD
    end
    !!meets_teacher_threshold
  end
  private_class_method :measures_with_sufficient_data
end
