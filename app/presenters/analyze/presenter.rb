module Analyze
  class Presenter
    attr_reader :params, :school, :academic_year

    def initialize(params:, school:, academic_year:)
      @params = params
      @school = school
      @academic_year = academic_year
    end

    def category
      @category ||= Category.find_by_category_id(params[:category]) || Category.order(:category_id).first
    end

    def categories
      @categories = Category.all.order(:category_id)
    end

    def subcategory
      @subcategory ||= Subcategory.find_by_subcategory_id(params[:subcategory]) || subcategories.first
    end

    def subcategories
      @subcategories = category.subcategories.order(:subcategory_id)
    end

    def measures
      @measures = subcategory.measures.order(:measure_id).includes(%i[admin_data_items subcategory])
    end

    def academic_years
      @academic_years = AcademicYear.order(:range).all
    end

    def selected_academic_years
      @selected_academic_years ||= begin
        year_params = params[:academic_years]
        return [] unless year_params

        year_params.split(",").map { |year| AcademicYear.find_by_range(year) }.compact
      end
    end

    def races
      @races ||= Race.all.order(designation: :ASC)
    end

    def selected_races
      @selected_races ||= begin
        race_params = params[:races]
        return races unless race_params

        race_params.split(",").map { |race| Race.find_by_slug race }.compact
      end
    end

    def ells
      @ells ||= Ell.all.order(slug: :ASC)
    end

    def selected_ells
      @selected_ells ||= begin
        ell_params = params[:ells]
        return ells unless ell_params

        ell_params.split(",").map { |ell| Ell.find_by_slug ell }.compact
      end
    end

    def speds
      @speds ||= Sped.all.order(id: :ASC)
    end

    def selected_speds
      @selected_speds ||= begin
        sped_params = params[:speds]
        return speds unless sped_params

        sped_params.split(",").map { |sped| Sped.find_by_slug sped }.compact
      end
    end

    def graphs
      @graphs ||= [Analyze::Graph::AllData.new,
                   Analyze::Graph::StudentsAndTeachers.new,
                   Analyze::Graph::StudentsByRace.new(races: selected_races),
                   Analyze::Graph::StudentsByGrade.new(grades: selected_grades),
                   Analyze::Graph::StudentsByGender.new(genders: selected_genders),
                   Analyze::Graph::StudentsByIncome.new(incomes: selected_incomes),
                   Analyze::Graph::StudentsByEll.new(ells: selected_ells),
                   Analyze::Graph::StudentsBySped.new(speds: selected_speds)]
    end

    def graph
      @graph ||= graphs.reduce(graphs.first) do |acc, graph|
        graph.slug == params[:graph] ? graph : acc
      end
    end

    def selected_grades
      @selected_grades ||= begin
        grade_params = params[:grades]
        return grades unless grade_params

        grade_params.split(",").map(&:to_i)
      end
    end

    def selected_genders
      @selected_genders ||= begin
        gender_params = params[:genders]
        return genders unless gender_params

        gender_params.split(",").sort.map { |gender| Gender.find_by_designation(gender) }.compact
      end
    end

    def genders
      @genders ||= Gender.all.order(designation: :ASC)
    end

    def groups
      @groups = [Analyze::Group::Ell.new, Analyze::Group::Gender.new, Analyze::Group::Grade.new, Analyze::Group::Income.new,
                 Analyze::Group::Race.new, Analyze::Group::Sped.new]
    end

    def group
      @group ||= groups.reduce(groups.first) do |acc, group|
        group.slug == params[:group] ? group : acc
      end
    end

    def slice
      @slice ||= slices.reduce(slices.first) do |acc, slice|
        slice.slug == params[:slice] ? slice : acc
      end
    end

    def slices
      source.slices
    end

    def source
      @source ||= sources.reduce(sources.first) do |acc, source|
        source.slug == params[:source] ? source : acc
      end
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

    def grades
      @grades ||= SurveyItemResponse.where(school:, academic_year:)
                                    .where.not(grade: nil)
                                    .group(:grade)
                                    .select(:response_id)
                                    .distinct(:response_id)
                                    .count.reject do |_key, value|
        value < 10
      end.keys
    end

    def incomes
      @incomes ||= Income.all
    end

    def selected_incomes
      @selected_incomes ||= begin
        income_params = params[:incomes]
        return incomes unless income_params

        income_params.split(",").map { |income| Income.find_by_slug(income) }.compact
      end
    end

    def cache_objects
      [subcategory,
       selected_academic_years,
       graph,
       selected_races,
       selected_grades,
       grades,
       selected_genders,
       genders,
       selected_ells,
       ells,
       selected_speds,
       speds]
    end
  end
end
