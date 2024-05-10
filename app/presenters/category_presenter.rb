# frozen_string_literal: true

class CategoryPresenter
  def initialize(category:)
    @category = category
  end

  def id
    @category.category_id
  end

  def name
    @category.name
  end

  def description
    @category.description
  end

  def short_description
    @category.short_description
  end

  def slug
    @category.slug
  end

  def icon_class
    icon_suffix = classes[name.to_sym]
    "fas fa-#{icon_suffix}"
  end

  def icon_color_class
    color_suffix = colors[name.to_sym]
    "color-#{color_suffix}"
  end

  def subcategories(academic_year:, school:)
    @category.subcategories.sort_by(&:subcategory_id).map do |subcategory|
      SubcategoryPresenter.new(
        subcategory:,
        academic_year:,
        school:
      )
    end
  end

  def to_model
    @category
  end

  private

  def colors
    { 'Teachers & Leadership': 'blue',
      'School Culture': 'red',
      'Resources': 'black',
      'Academic Learning': 'lime',
      'Community & Wellbeing': 'teal' }
  end

  def classes
    { 'Teachers & Leadership': 'apple-alt',
      'School Culture': 'school',
      'Resources': 'users-cog',
      'Academic Learning': 'graduation-cap',
      'Community & Wellbeing': 'heart' }
  end
end
