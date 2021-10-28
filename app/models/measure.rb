class Measure < ActiveRecord::Base
  belongs_to :subcategory
  has_many :survey_items
  has_many :admin_data_items

  has_many :survey_item_responses, through: :survey_items

  scope :source_includes_survey_items, ->() { joins(:survey_items).uniq }

  def teacher_survey_items
    @teacher_survey_items ||= survey_items.where("survey_item_id LIKE 't-%'")
  end

  def student_survey_items
    @student_survey_items ||= survey_items.where("survey_item_id LIKE 's-%'")
  end

  def includes_teacher_survey_items?
    teacher_survey_items.any?
  end

  def includes_student_survey_items?
    student_survey_items.any?
  end

end
