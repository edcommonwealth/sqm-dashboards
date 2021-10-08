class SubcategoryCardPresenter

  def initialize(scale:, score:)
    @scale = scale
    @score = score
  end

  def display_icon?
    zone.type != :no_zone
  end

  def harvey_ball_icon
    icons_by_zone_type = {
      ideal: "full-circle",
      approval: "three-quarter-circle",
      growth: "half-circle",
      watch: "one-quarter-circle",
      warning: "empty-circle",
      no_zone: "empty-circle"
    }
    icons_by_zone_type[zone.type]
  end

  def color
    zone.type.to_s
  end

  private

  def zone
    @scale.zone_for_score(@score)
  end
end
