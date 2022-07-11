# frozen_string_literal: true

class SubcategoryCardPresenter
  attr_reader :name, :subcategory, :category, :subcategory_id

  def initialize(subcategory:, zones:, score:)
    @name = subcategory.name
    @subcategory = subcategory
    @category = subcategory.category
    @subcategory_id = subcategory.subcategory_id
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
    subcategory
  end

  private

  def zone
    @zones.zone_for_score(@score)
  end
end
