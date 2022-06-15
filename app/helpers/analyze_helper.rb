module AnalyzeHelper
  def zone_label_width
    15
  end

  def zone_label_x
    2
  end

  def analyze_graph_height
    85
  end

  def svg_height
    400
  end

  def graph_width
    85
  end

  def benchmark_y
    (analyze_zone_height * 2) - (benchmark_height / 2.0)
  end

  def benchmark_height
    1
  end

  def grouped_chart_column_width
    graph_width / data_sources
  end

  def column_end_x(position)
    zone_label_width + (grouped_chart_column_width * position)
  end

  def column_start_x(position)
    column_end_x(position - 1)
  end

  def bar_label_height
    (100 - ((100 - analyze_graph_height) / 2))
  end

  def analyze_zone_height
    analyze_graph_height / 5
  end

  def zone_height_percentage
    analyze_zone_height / 100.0
  end

  def zone_label_y(position)
    8.5 * (position + position - 1)
  end

  def data_sources
    3
  end

  def analyze_category_link(district:, school:, academic_year:, category:)
    "/districts/#{district.slug}/schools/#{school.slug}/analyze?year=#{academic_year.range}&academic_years=#{academic_year.range}&category=#{category.category_id}"
  end

  def analyze_subcategory_link(district:, school:, academic_year:, category:, subcategory:)
    "/districts/#{district.slug}/schools/#{school.slug}/analyze?year=#{academic_year.range}&category=#{category.category_id}&subcategory=#{subcategory.subcategory_id}"
  end

  def colors
    @colors ||= ['#49416D', '#FFC857', '#920020', '#00B0B3', '#B2D236', '#004D61']
  end

  def empty_dataset?(measures:, school:, academic_year:)
    @empty_dataset ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = measures.all? do |measure|
        response_rate = measure.subcategory.response_rate(school:, academic_year:)
        !response_rate.meets_student_threshold && !response_rate.meets_teacher_threshold
      end
    end

    @empty_dataset[[school, academic_year]]
  end
end
