class CategoryPresenter
  def initialize(category:, academic_year:, school:)
    @category = category
    @academic_year = academic_year
    @school = school
  end

  def name
    @category.name
  end

  def description
    @category.description
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
    else 'Citizenship & Wellbeing'
       'heart'
    end
  end

  def subcategories
    @category.subcategories.map do |subcategory|
      SubcategoryPresenter.new(
        subcategory: subcategory,
        academic_year: @academic_year,
        school: @school
      )
    end
  end

  def to_model
    @category
  end
end
