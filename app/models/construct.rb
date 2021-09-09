class Construct
  Zone = Struct.new(:low_benchmark, :high_benchmark, :type) do
    def includes_score?(score)
      score > low_benchmark and score < high_benchmark
    end
  end

  attr_reader :title, :warning_zone, :watch_zone, :growth_zone, :approval_zone, :ideal_zone

  def initialize(title:, watch_low_benchmark:, growth_low_benchmark:, approval_low_benchmark:, ideal_low_benchmark:)
    @title = title
    @warning_zone = Zone.new(1, watch_low_benchmark, :warning)
    @watch_zone = Zone.new(watch_low_benchmark, growth_low_benchmark, :watch)
    @growth_zone = Zone.new(growth_low_benchmark, approval_low_benchmark, :growth)
    @approval_zone = Zone.new(approval_low_benchmark, ideal_low_benchmark, :approval)
    @ideal_zone = Zone.new(ideal_low_benchmark, 5, :ideal)
  end

  def zone_for_score(score)
    case score
    when ideal_zone.low_benchmark..ideal_zone.high_benchmark
      ideal_zone
    when approval_zone.low_benchmark..approval_zone.high_benchmark
      approval_zone
    when growth_zone.low_benchmark..growth_zone.high_benchmark
      growth_zone
    when watch_zone.low_benchmark..watch_zone.high_benchmark
      watch_zone
    else
      warning_zone
    end
  end
end
