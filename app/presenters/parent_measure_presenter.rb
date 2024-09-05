# frozen_string_literal: true

class ParentMeasurePresenter < MeasurePresenter
  def measure_id
    "#{measure.measure_id} (Parent)"
  end

  def score_for_measure
    @measure.parent_score(school: @school, academic_year: @academic_year)
  end

  def data_item_presenters
    [].tap do |array|
      array << parent_survey_presenter if measure.parent_survey_items.any?
    end
  end

  private

  def parent_survey_presenter
    ParentSurveyPresenter.new(measure_id: measure.measure_id, survey_items: measure.parent_survey_items,
                              has_sufficient_data: true, school:, academic_year:)
  end
end
