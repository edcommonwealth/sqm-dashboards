class SubcategoryCardPresenter 

  def initialize(scale:, score:)
    @scale = scale
    @score = score
  end

  def abbreviation
    abbreviations = { approval: "A", ideal: "I", growth: "G", watch: "Wa", warning: "Wr" , no_zone: "N"}
    abbreviations[zone.type]
  end

  def svg

  end

  def offset
    return 40 unless abbreviation.length > 1
    27
  end

  def color
    case zone.type
    when :warning
      return "fill-warning"
    when :watch
      return "fill-watch"
    when :growth
      return "fill-growth"
    when :approval
      return "fill-approval"
    when :ideal
      return "fill-ideal"
    else
      return "fill-warning"
    end

  end

  private

  def zone
    @scale.zone_for_score(@score)
  end
end
