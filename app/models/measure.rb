class Measure < ActiveRecord::Base
  belongs_to :subcategory
  has_many :survey_items

  has_many :survey_item_responses, through: :survey_items

  def includes_teacher_survey_items?
    survey_items.where("survey_item_id LIKE 't-%'").any?
  end

  def includes_student_survey_items?
    survey_items.where("survey_item_id LIKE 's-%'").any?
  end
end
