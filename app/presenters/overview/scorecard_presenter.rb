# frozen_string_literal: true

class Overview::ScorecardPresenter
  attr_reader :name, :construct, :category, :id

  def initialize(construct:, zones:, score:, id:)
    @name = construct.name
    @category = construct.category
    @id = id
    @zones = zones
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

  def to_model
    construct
  end

  private

  def zone
    @zones.zone_for_score(@score)
  end
end
