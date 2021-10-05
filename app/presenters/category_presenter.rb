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

  def subcategories
    @category.subcategories.map do |subcategory|
      SubcategoryPresenter.new(
        subcategory: subcategory,
        academic_year: @academic_year,
        school: @school,
      )
    end
  end
end
