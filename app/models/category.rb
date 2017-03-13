class Category < ApplicationRecord

  has_many :questions
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_category_id
  has_many :child_categories, class_name: 'Category', foreign_key: :parent_category_id
  has_many :school_categories

  validates :name, presence: true

  scope :for_parent, -> (category=nil) { where(parent_category_id: category.try(:id)) }

  def root_identifier
    p = self
    while p.parent_category.present?
      p = p.parent_category
    end
    p.name.downcase.gsub(/\s/, '-')
  end

  def root_index
    [
      "teachers-and-the-teaching-environment",
      "school-culture",
      "resources",
      "indicators-of-academic-learning",
      "character-and-wellbeing-outcomes"
    ].index(root_identifier)
  end

end
