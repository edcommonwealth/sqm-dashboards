Point = Struct.new(:x, :y)
Rect = Struct.new(:x, :y, :width, :height)

module GaugeHelper
  def outer_radius
    100
  end

  def inner_radius
    50
  end

  def stroke_width
    1
  end

  def key_benchmark_indicator_gutter
    10
  end

  def viewbox
    x = arc_center.x - (outer_radius + stroke_width)
    y = arc_center.y - (outer_radius + stroke_width) - key_benchmark_indicator_gutter
    width = 2*(outer_radius + stroke_width)
    height = outer_radius + 2*stroke_width + key_benchmark_indicator_gutter
    Rect.new(x, y, width, height)
  end

  def arc_center
    Point.new(0, 0)
  end

  def indicator_tip
    Point.new(arc_center.x, arc_center.y - outer_radius - 2)
  end

  def indicator_right_corner
    Point.new(key_benchmark_indicator_gutter/Math.sqrt(3), arc_center.y - outer_radius - key_benchmark_indicator_gutter)
  end

  def indicator_left_corner
    Point.new(-key_benchmark_indicator_gutter/Math.sqrt(3), arc_center.y - outer_radius - key_benchmark_indicator_gutter)
  end

  def arc_radius(radius)
    "#{radius} #{radius}"
  end

  def angle_for(percentage:)
    -Math::PI * (1 - percentage)
  end

  def arc_end_point_for(radius:, percentage:)
    angle = angle_for(percentage: percentage)

    x = arc_center.x + radius * Math.cos(angle)
    y = arc_center.y + radius * Math.sin(angle)
    Point.new(x, y)
  end

  def arc_end_line_destination(radius:, percentage:)
    x = arc_center.x + radius * Math.cos(angle_for(percentage: percentage))
    y = arc_center.y + radius * Math.sin(angle_for(percentage: percentage))
    Point.new(x, y)
  end

  def arc_start_point
    Point.new(arc_center.x - outer_radius, arc_center.y)
  end

  def move_to(point:)
    "M #{coordinates_for(point)}"
  end

  def draw_arc(radius:, percentage:, clockwise:)
    sweep_flag = clockwise ? 1 : 0
    "A #{arc_radius(radius)} 0 0 #{sweep_flag} #{coordinates_for(arc_end_point_for(radius: radius, percentage: percentage))}"
  end

  def draw_line_to(point:)
    "L #{coordinates_for(point)}"
  end

  def benchmark_line_point(radius, angle)
    x = "#{radius * Math.cos(angle)}"
    y = "#{radius * Math.sin(angle) + arc_center.y}"
    Point.new(x, y)
  end

  def rotation_angle_for(percentage:)
    180.0 * percentage - 90
  end

  def coordinates_for(point)
    "#{point.x} #{point.y}"
  end
end