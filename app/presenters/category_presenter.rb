# frozen_string_literal: true

class CategoryPresenter
  def initialize(category:)
    @category = category
  end

  def id
    @category.category_id
  end

  def name
    @category.name
  end

  def description
    @category.description
  end

  def short_description
    @category.short_description
  end

  def slug
    @category.slug
  end

  def icon_class
    icon_suffix = classes[id.to_sym]
    "fas fa-#{icon_suffix}"
  end

  def icon_color_class
    color_suffix = colors[id.to_sym]
    "color-#{color_suffix}"
  end

  def filtered_and_sorted_subcategories(school:)
    # Category 4D is only made up of high school only measures, so we exclude it for non-high school users
    if school.is_hs
      @category.subcategories.sort_by(&:subcategory_id)
    else
      @category.subcategories.reject { |subcategory| subcategory.subcategory_id == "4D" }.sort_by(&:subcategory_id)
    end
  end

  def subcategories(academic_year:, school:)
    filtered_and_sorted_subcategories(school:).map do |subcategory|
      SubcategoryPresenter.new(
        subcategory:,
        academic_year:,
        school:
      )
    end
  end

  def harvey_scorecard_presenters(school:, academic_year:)
    filtered_and_sorted_subcategories(school:).map do |subcategory|
      measures = subcategory.measures
      zones = Zones.new(
        watch_low_benchmark: measures.map(&:watch_low_benchmark).average,
        growth_low_benchmark: measures.map(&:growth_low_benchmark).average,
        approval_low_benchmark: measures.map(&:approval_low_benchmark).average,
        ideal_low_benchmark: measures.map(&:ideal_low_benchmark).average
      )

      Overview::ScorecardPresenter.new(construct: subcategory,
                                       zones:,
                                       score: subcategory.score(school:, academic_year:),
                                       id: subcategory.subcategory_id)
    end
  end

  def to_model
    @category
  end

  def show_parent_view?(school:, academic_year:)
    subcategories(school:, academic_year:).any? { |subcategory| subcategory.show_scale_presenters? }
  end

  private

  def colors
    { '1': "blue",
      '2': "red",
      '3': "black",
      '4': "lime",
      '5': "teal" }
  end

  def classes
    { '1': "apple-alt",
      '2': "school",
      '3': "users-cog",
      '4': "graduation-cap",
      '5': "heart" }
  end
end
