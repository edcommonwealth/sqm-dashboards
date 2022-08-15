class Sample
  attr_reader :school, :academic_year, :category, :measure, :race

  def initialize(slug: 'milford-high-school', range: '2021-22', category_id: '1', subcategory_id: '1A',
                 measure_id: '1A-ii', race_code: 1)
    @school = School.find_by_slug slug
    @academic_year = AcademicYear.find_by_range range
    @category = Category.find_by_category_id category_id
    @subcategory = Subcategory.find_by_subcategory_id subcategory_id
    @measure = Measure.find_by_measure_id measure_id
    @race = Race.find_by_qualtrics_code race_code
  end
end
