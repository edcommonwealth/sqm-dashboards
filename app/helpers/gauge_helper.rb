# frozen_string_literal: true

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

  def effective_radius
    outer_radius + stroke_width
  end

  def diameter
    2 * effective_radius
  end

  def width
    diameter
  end

  def height
    outer_radius + 2 * stroke_width + key_benchmark_indicator_gutter
  end

  def key_benchmark_indicator_gutter
    10
  end

  def viewbox
    x = arc_center.x - effective_radius
    y = arc_center.y - effective_radius - key_benchmark_indicator_gutter
    Rect.new(x, y, width, height)
  end

  def arc_center
    Point.new(0, 0)
  end

  def arc_radius(radius)
    "#{radius} #{radius}"
  end

  def angle_for(percentage:)
    -Math::PI * (1 - percentage)
  end

  def arc_end_point_for(radius:, percentage:)
    angle = angle_for(percentage:)

    x = arc_center.x + radius * Math.cos(angle)
    y = arc_center.y + radius * Math.sin(angle)
    Point.new(x, y)
  end

  def arc_end_line_destination(radius:, percentage:)
    angle = angle_for(percentage:)
    x = arc_center.x + radius * Math.cos(angle)
    y = arc_center.y + radius * Math.sin(angle)
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
    "A #{arc_radius(radius)} 0 0 #{sweep_flag} #{coordinates_for(arc_end_point_for(radius:,
                                                                                   percentage:))}"
  end

  def draw_line_to(point:)
    "L #{coordinates_for(point)}"
  end

  def benchmark_line_point(radius, angle)
    x = (radius * Math.cos(angle)).to_s
    y = (radius * Math.sin(angle) + arc_center.y).to_s
    Point.new(x, y)
  end

  def coordinates_for(point)
    "#{point.x} #{point.y}"
  end
end
