class Measure < ActiveRecord::Base
  belongs_to :subcategory
  has_many :survey_items
  has_many :admin_data_items

  has_many :survey_item_responses, through: :survey_items

  scope :source_includes_survey_items, -> { joins(:survey_items).uniq }

  def self.none_meet_threshold?(school:, academic_year:)
    none? do |measure|
      SurveyItemResponse.sufficient_data?(measure: measure, school: school, academic_year: academic_year)
    end
  end

  def teacher_survey_items
    @teacher_survey_items ||= survey_items.where("survey_item_id LIKE 't-%'")
  end

  def student_survey_items
    @student_survey_items ||= survey_items.where("survey_item_id LIKE 's-%'")
  end

  def includes_teacher_survey_items?
    @includes_teacher_survey_items ||= teacher_survey_items.any?
  end

  def includes_student_survey_items?
    @includes_student_survey_items ||= student_survey_items.any?
  end

  def includes_admin_data_items?
    @includes_admin_data_items ||= admin_data_items.any?
  end

  def sources
    sources = []
    sources << :admin_data if includes_admin_data_items?
    sources << :student_surveys if includes_student_survey_items?
    sources << :teacher_surveys if includes_teacher_survey_items?
    sources
  end

  def warning_low_benchmark
    return @warning_low_benchmark unless @warning_low_benchmark.nil?

    @warning_low_benchmark = benchmark(:warning_low_benchmark)
  end

  def watch_low_benchmark
    return @watch_low_benchmark unless @watch_low_benchmark.nil?

    @watch_low_benchmark = benchmark(:watch_low_benchmark)
  end

  def growth_low_benchmark
    return @growth_low_benchmark unless @growth_low_benchmark.nil?

    @growth_low_benchmark = benchmark(:growth_low_benchmark)
  end

  def approval_low_benchmark
    return @approval_low_benchmark unless @approval_low_benchmark.nil?

    @approval_low_benchmark = benchmark(:approval_low_benchmark)
  end

  def ideal_low_benchmark
    return @ideal_low_benchmark unless @ideal_low_benchmark.nil?

    @ideal_low_benchmark = benchmark(:ideal_low_benchmark)
  end

  private

  def benchmark(name)
    averages = []
    averages << student_survey_items.first.send(name) if includes_student_survey_items?
    averages << teacher_survey_items.first.send(name) if includes_teacher_survey_items?
    (averages << admin_data_items.map(&name)).flatten! if includes_admin_data_items?

    averages.average
  end
end
