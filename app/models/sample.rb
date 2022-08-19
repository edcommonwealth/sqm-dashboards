class Sample
  attr_reader :school, :academic_year, :category, :measure, :race

  def initialize(slug: 'a-irvin-studley-elementary-school', range: '2020-21', category_id: '1', subcategory_id: '1A',
                 measure_id: '1A-ii', race_code: 5)
    @school = School.find_by_slug slug
    @academic_year = AcademicYear.find_by_range range
    @category = Category.find_by_category_id category_id
    @subcategory = Subcategory.find_by_subcategory_id subcategory_id
    @measure = Measure.find_by_measure_id measure_id
    @race = Race.find_by_qualtrics_code race_code
  end

  def count_students(school: @school, academic_year: @academic_year, race: @race)
    students = StudentRace.where(race:).pluck(:student_id).uniq
    SurveyItemResponse.where(school:, academic_year:,
                             student: students).map(&:student).uniq.count
  end

  def count_all_students(school: @school, academic_year: @academic_year)
    SurveyItemResponse.where(school:, academic_year:).map(&:student).uniq.count
  end
end
