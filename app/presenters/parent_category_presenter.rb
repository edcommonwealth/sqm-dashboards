class ParentCategoryPresenter < CategoryPresenter
  def harvey_scorecard_presenters(school:, academic_year:)
    @category.scales.parent_scales.map do |scale|
      measure = scale.measure
      zones = Zones.new(
        watch_low_benchmark: measure.watch_low_benchmark,
        growth_low_benchmark: measure.growth_low_benchmark,
        approval_low_benchmark: measure.approval_low_benchmark,
        ideal_low_benchmark: measure.ideal_low_benchmark
      )

      Overview::ScorecardPresenter.new(construct: scale,
                                       zones:,
                                       score: scale.parent_score(school:, academic_year:),
                                       id: scale.scale_id)
    end
  end
end
