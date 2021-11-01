class SubcategoryCardPresenter
  attr_reader :name

  def initialize(name:, scale:, score:)
    @name = name
    @scale = scale
    @score = score
  end

  def harvey_ball_icon
    icons_by_zone_type = {
      ideal: "full-circle",
      approval: "three-quarter-circle",
      growth: "half-circle",
      watch: "one-quarter-circle",
      warning: "full-circle",
      insufficient_data: "full-circle"
    }
    icons_by_zone_type[zone.type]
  end

  def color
    zone.type.to_s
  end

  def insufficient_data?
    zone.type == :insufficient_data
  end

  private

  def zone
    @scale.zone_for_score(@score)
  end
end
