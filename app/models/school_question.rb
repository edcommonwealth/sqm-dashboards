class SchoolQuestion < ApplicationRecord

  belongs_to :school
  belongs_to :question
  belongs_to :school_category

  validates_associated :school
  validates_associated :question
  validates_associated :school_category

  scope :for, -> (school, question) { where(school_id: school.id, question_id: question.id) }

end
