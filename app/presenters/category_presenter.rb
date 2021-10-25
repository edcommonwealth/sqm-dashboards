class CategoryPresenter
  attr_reader :category

  def initialize(category:)
    @category = category
  end

  def name
    @category.name
  end

  def description
    @category.description
  end

  def slug
    @category.slug
  end

  def icon
    case name
    when 'Teachers & Leadership'
      'apple-alt'
    when 'School Culture'
      'school'
    when 'Resources'
      'users-cog'
    when 'Academic Learning'
      'graduation-cap'
    else 'Community & Wellbeing'
       'heart'
    end
  end

  def subcategories(academic_year:, school:)
    @category.subcategories.map do |subcategory|
      SubcategoryPresenter.new(
        subcategory: subcategory,
        academic_year: academic_year,
        school: school
      )
    end
  end

  def to_model
    @category
  end
end
