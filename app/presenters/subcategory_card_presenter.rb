class SubcategoryCardPresenter
  attr_reader :name

  def initialize(name:, scale:, score:)
    @name = name
    @scale = scale
    @score = score
  end

  def harvey_ball_icon
    "#{zone.type}-harvey-ball"
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
