# frozen_string_literal: true

class AnalyzeController < SqmApplicationController
  before_action :assign_categories, :assign_subcategories, :assign_measures, :assign_academic_years,
                :response_rate_timestamp, :races, :selected_races, :graph, :graphs, :background, :race_score_timestamp,
                :source, :sources, :group, :groups, :selected_grades, :grades, :slice, :selected_genders, :genders, only: [:index]
  def index; end

  private

  def assign_categories
    @category ||= Category.find_by_category_id(params[:category])
    @category ||= Category.order(:category_id).first
    @categories = Category.all.order(:category_id)
  end

  def assign_subcategories
    @subcategories = @category.subcategories.order(:subcategory_id)
    @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory])
    @subcategory ||= @subcategories.first
  end

  def assign_measures
    @measures = @subcategory.measures.order(:measure_id).includes(%i[admin_data_items subcategory])
  end

  def assign_academic_years
    @available_academic_years = AcademicYear.order(:range).all
    year_params = params[:academic_years]
    @academic_year_params = year_params.split(',') if year_params
    @selected_academic_years = []
    @academic_year_params ||= []
    @academic_year_params.each do |year|
      @selected_academic_years << AcademicYear.find_by_range(year)
    end
  end

  def response_rate_timestamp
    @response_rate_timestamp = begin
      academic_year = @selected_academic_years.last
      academic_year ||= @academic_year
      rate = ResponseRate.where(school: @school,
                                academic_year:).order(updated_at: :DESC).first || Today.new

      rate.updated_at
    end
    @response_rate_timestamp
  end

  def races
    @races ||= Race.all.order(designation: :ASC)
  end

  def selected_races
    @selected_races ||= begin
      race_params = params[:races]
      return @selected_races = races unless race_params

      race_list = race_params.split(',') if race_params
      if race_list
        race_list = race_list.map do |race|
          Race.find_by_slug race
        end
      end
      race_list
    end
  end

  def graph
    graphs.each do |graph|
      @graph = graph if graph.slug == params[:graph]
    end

    @graph ||= graphs.first
  end

  def graphs
    @graphs ||= [Analyze::Graph::AllData.new, Analyze::Graph::StudentsAndTeachers.new, Analyze::Graph::StudentsByRace.new(races: selected_races),
                 Analyze::Graph::StudentsByGrade.new(grades: selected_grades), Analyze::Graph::StudentsByGender.new(genders: selected_genders)]
  end

  def background
    @background ||= BackgroundPresenter.new(num_of_columns: graph.columns.count)
  end

  def race_score_timestamp
    @race_score_timestamp ||= begin
      score = RaceScore.where(school: @school,
                              academic_year: @academic_year).order(updated_at: :DESC).first || Today.new
      score.updated_at
    end
  end

  def source
    source_param = params[:source]
    sources.each do |source|
      @source = source if source.slug == source_param
    end

    @source ||= sources.first
  end

  def sources
    all_data_slices = [Analyze::Slice::AllData.new]
    all_data_source = Analyze::Source::AllData.new(slices: all_data_slices)

    students_and_teachers = Analyze::Slice::StudentsAndTeachers.new
    students_by_group = Analyze::Slice::StudentsByGroup.new(races:, grades:)
    survey_data_slices = [students_and_teachers, students_by_group]
    survey_data_source = Analyze::Source::SurveyData.new(slices: survey_data_slices)

    @sources = [all_data_source, survey_data_source]
  end

  def slice
    slice_param = params[:slice]
    slices.each do |slice|
      @slice = slice if slice.slug == slice_param
    end

    @slice ||= slices.first
  end

  def slices
    source.slices
  end

  def group
    groups.each do |group|
      @group = group if group.slug == params[:group]
    end

    @group ||= groups.first
  end

  def groups
    @groups = [Analyze::Group::Race.new, Analyze::Group::Grade.new, Analyze::Group::Gender.new]
  end

  def selected_grades
    @selected_grades ||= begin
      grade_params = params[:grades]
      return @selected_grades = grades unless grade_params

      grade_list = grade_params.split(',') if grade_params
      if grade_list
        grade_list = grade_list.map do |grade|
          grade.to_i
        end
      end
      grade_list
    end
  end

  def grades
    @grades ||= SurveyItemResponse.where(school: @school, academic_year: @academic_year)
                                  .where.not(grade: nil)
                                  .group(:grade)
                                  .select(:response_id)
                                  .distinct(:response_id)
                                  .count.reject do |_key, value|
                                    value < 10
                                  end.keys
  end

  def selected_genders
    @selected_genders ||= begin
      gender_params = params[:genders]
      return @selected_genders = genders unless gender_params

      gender_list = gender_params.split(',') if gender_params
      if gender_list
        gender_list = gender_list.map do |gender|
          Gender.find_by_designation(gender)
        end
      end
      gender_list
    end
  end

  def genders
    @genders ||= Gender.all
  end
end
