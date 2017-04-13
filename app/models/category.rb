class Category < ApplicationRecord

  has_many :questions
  belongs_to :parent_category, class_name: 'Category', foreign_key: :parent_category_id
  has_many :child_categories, class_name: 'Category', foreign_key: :parent_category_id
  has_many :school_categories

  validates :name, presence: true

  scope :for_parent, -> (category=nil) { where(parent_category_id: category.try(:id)) }

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  def path
    p = self
    items = [p]
    items << p while (p = p.try(:parent_category))
    items.uniq.compact.reverse
  end

  def root_identifier
    path.first.name.downcase.gsub(/\s/, '-')
  end

  def root_index
    [
      "teachers-and-the-teaching-environment",
      "school-culture",
      "resources",
      "indicators-of-academic-learning",
      "character-and-wellbeing-outcomes",
      "pilot-family-questions"
    ].index(root_identifier)
  end

end
