class Sample
  attr_reader :school, :academic_year, :category, :measure, :race

  def initialize
    @school = School.find_by_slug 'milford-high-school'
    @academic_year = AcademicYear.last
    @category = Category.find_by_category_id '1'
    @subcategory = Subcategory.find_by_subcategory_id '1A'
    @measure = Measure.find_by_measure_id '1A-ii'
    @race = Race.find_by_qualtrics_code 1
  end
end
