module Analyze
  class Presenter
    attr_reader :params, :school, :academic_year

    def initialize(params:, school:, academic_year:)
      @params = params
      @school = school
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
        array = []

        keys = params.keys.select { |key| key.start_with? "academic_year" }
        keys.each do |key|
          year_params = params[key]&.chomp
          next if year_params.nil?

          array << AcademicYear.find_by_range(year_params)
        end
        array
      end
    end

    def races
      @races ||= Race.all.order(designation: :ASC)
    end

    def selected_races
      @selected_races ||= selected_items(name: "race", list: races)
    end

    def ells
      @ells ||= Ell.all.order(slug: :ASC)
    end

    def selected_ells
      @selected_ells ||= selected_items(name: "ell", list: ells)
    end

    def selected_items(name:, list:)
      selected_params = params.select { |key, _| key.start_with?(name) && key.end_with?("checkbox") }
      return list unless selected_params.keys.length.positive?

      selected_params.values
                     .map { |slug| list.find { |item| item.slug == slug } }
    end

    def speds
      @speds ||= Sped.all.order(id: :ASC)
    end

    def selected_speds
      @selected_speds ||= selected_items(name: "sped", list: speds)
    end

    def selected_grades
      @selected_grades ||= begin
        selected_params = params.select { |key, _| key.start_with?("grade") && key.end_with?("checkbox") }
        return grades unless selected_params.keys.length.positive?

        selected_params.values.map(&:to_i)
      end
    end

    def selected_genders
      @selected_genders ||= selected_items(name: "gender", list: genders)
    end

    def genders
      @genders ||= Gender.all.order(designation: :ASC)
    end

    def groups
      @groups ||=
        begin
          first_char_of_class_name = graph.class.name.demodulize.first
          graphs.select { |graph| graph.class.name.demodulize.first == first_char_of_class_name }.map(&:group)
                .reject { |group| group.name.nil? }
                .sort_by { |group| group.name }
                .uniq { |group| group.slug }
        end
    end

    def group
      @group ||= groups.reduce(groups.first) do |acc, group|
        group.slug == params[:group] ? group : acc
      end
    end

    def slice
      @slice ||= graph.slice || slices.first
    end

    def slices
      @slices ||= begin
        hash = {}
        graphs.map(&:slice).each do |slice|
          hash[slice.slug] = slice
        end
        hash.values
      end
    end

    def source
      @source ||= graph&.source || sources.first
    end

    def show_secondary_graph?(measure:)
      return false unless measure.includes_parent_survey_items?

      ["all-data", "students-and-teachers-and-parents"].include?(requested_graphs)
    end

    def show_scale_level_graphs?(measure:)
      return false unless measure.includes_parent_survey_items?

      requested_graphs.starts_with? "parents-by"
    end

    def sources
      @sources ||= begin
        hash = {}
        graphs.map(&:source).each do |source|
          hash[source.slug] = source
        end
        hash.values
      end
    end

    def measure_level_graphs
      @measure_level_graphs ||= { "all-data" => Analyze::Graph::AllData.new,
                                  "students-and-teachers" => Analyze::Graph::StudentsAndTeachers.new,
                                  "students-and-teachers-and-parents" => Analyze::Graph::StudentsAndTeachersAndParents.new,
                                  "students-by-race" => Analyze::Graph::StudentsByRace.new(races: selected_races),
                                  "students-by-grade" => Analyze::Graph::StudentsByGrade.new(grades: selected_grades),
                                  "students-by-gender" => Analyze::Graph::StudentsByGender.new(genders: selected_genders),
                                  "students-by-income" => Analyze::Graph::StudentsByIncome.new(incomes: selected_incomes),
                                  "students-by-sped" => Analyze::Graph::StudentsBySped.new(speds: selected_speds),
                                  "students-by-ell" => Analyze::Graph::StudentsByEll.new(ells: selected_ells),
                                  "parents-by-language" => Analyze::Graph::ParentsByLanguage.new,
                                  "parents-by-race" => Analyze::Graph::ParentsByRace.new }
    end

    def scale_level_graphs
      @scale_level_graphs ||= { "all-data" => nil,
                                "students-and-teachers" => nil,
                                "students-and-teachers-and-parents" => nil,
                                "students-by-race" => nil,
                                "students-by-grade" => nil,
                                "students-by-gender" => nil,
                                "students-by-income" => nil,
                                "students-by-sped" => nil,
                                "students-by-ell" => nil,
                                "parents-by-language" => Analyze::Graph::ParentsByLanguage.new,
                                "parents-by-race" => Analyze::Graph::ParentsByRace.new }
    end

    def graphs
      @graphs ||= measure_level_graphs.values
    end

    def graph
      measure_level_graph
    end

    def requested_graphs
      @requested_graphs ||= params[:graph] || "all-data"
    end

    def secondary_graph
      @secondary_graph ||= Analyze::Graph::AllParent.new
    end

    def scale_level_graph
      @scale_level_graph ||= scale_level_graphs[requested_graphs] || Analyze::Graph::ParentsByLanguageByScale.new
    end

    def measure_level_graph
      @measure_level_graph ||= measure_level_graphs[requested_graphs] || Analyze::Graph::AllData.new
    end

    def grades
      @grades ||= SurveyItemResponse.where(school:, academic_year: academic_years)
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
      @selected_incomes ||= selected_items(name: "income", list: incomes)
    end

    def cache_objects
      [category,
       subcategory,
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
