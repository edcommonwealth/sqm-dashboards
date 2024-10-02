# frozen_string_literal: true

class ParentScalePresenter
  attr_reader :scale, :academic_year, :school, :name, :description, :id

  def initialize(scale:, academic_year:, school:)
    @scale = scale
    @academic_year = academic_year
    @school = school
    @name = scale.name
    @description = scale.description
    @id = scale.scale_id
  end

  def title
    "Scale #{scale.scale_id}"
  end

  def gauge_presenter
    GaugePresenter.new(zones:,
                       score:)
  end

  def data_item_accordion_id
    "data-item-accordion-#{@scale.scale_id}"
  end

  def data_item_presenters
    [].tap do |array|
      array << parent_survey_presenter if scale.survey_items.parent_survey_items.any?
    end
  end

  def score
    @score ||= SurveyItemResponse.where(survey_item: scale.survey_items.parent_survey_items, school:,
                                        academic_year:)
                                 .having("count(*) > 10")
                                 .group(:survey_item)
                                 .average(:likert_score)
                                 .values.average
  end

  private

  def scale_id
    scale.scale_id
  end

  def parent_survey_presenter
    ParentSurveyPresenter.new(scale_id:, survey_items: scale.survey_items.parent_survey_items,
                              has_sufficient_data: score.positive?, school:, academic_year:)
  end

  def zones
    Zones.new(
      watch_low_benchmark: @scale.measure.watch_low_benchmark,
      growth_low_benchmark: @scale.measure.growth_low_benchmark,
      approval_low_benchmark: @scale.measure.approval_low_benchmark,
      ideal_low_benchmark: @scale.measure.ideal_low_benchmark
    )
  end
end
