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
      "academic-learning",
      "citizenship-and-wellbeing",
      "pilot-family-questions"
    ].index(root_identifier) || 0
  end

  def zone_widths
    return nil if zones.nil?
    split_zones = zones.split(",")
    split_zones.each_with_index.map do |zone, index|
      (zone.to_f - (index == 0 ? 0 : split_zones[index - 1]).to_f).round(2)
    end
  end

end
