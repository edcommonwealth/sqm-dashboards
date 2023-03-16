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
    icon_suffix = classes[id.to_sym]
    "fas fa-#{icon_suffix}"
  end

  def icon_color_class
    color_suffix = colors[id.to_sym]
    "color-#{color_suffix}"
  end

  def subcategories(academic_year:, school:)
    @category.subcategories.includes([:measures]).sort_by(&:subcategory_id).map do |subcategory|
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
    { '1': 'blue',
      '2': 'red',
      '3': 'black',
      '4': 'lime',
      '5': 'teal' }
  end

  def classes
    { '1': 'apple-alt',
      '2': 'school',
      '3': 'users-cog',
      '4': 'graduation-cap',
      '5': 'heart' }
  end
end
