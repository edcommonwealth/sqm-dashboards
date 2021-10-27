class CategoryPresenter
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

  def icon_class
    icon_suffix = case name
                  when 'Teachers & Leadership'
                    'apple-alt'
                  when 'School Culture'
                    'school'
                  when 'Resources'
                    'users-cog'
                  when 'Academic Learning'
                    'graduation-cap'
                  when 'Community & Wellbeing'
                    'heart'
                  end
    "fas fa-#{icon_suffix}"
  end

  def icon_color_class
    color_suffix = case name
                   when 'Teachers & Leadership'
                     'blue'
                   when 'School Culture'
                     'red'
                   when 'Resources'
                     'black'
                   when 'Academic Learning'
                     'lime'
                   when 'Community & Wellbeing'
                     'teal'
                   end
    "color-#{color_suffix}"
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
