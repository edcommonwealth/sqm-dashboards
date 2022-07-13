# frozen_string_literal: true

module HeaderHelper
  def link_to_overview(district:, school:, academic_year:)
    "/districts/#{district.slug}/schools/#{school.slug}/overview?year=#{academic_year.range}"
  end

  def link_to_browse(district:, school:, academic_year:)
    "/districts/#{district.slug}/schools/#{school.slug}/browse/teachers-and-leadership?year=#{academic_year.range}"
  end

  def link_to_analyze(district:, school:, academic_year:)
    year = academic_year.range
    "/districts/#{district.slug}/schools/#{school.slug}/analyze?year=#{year}&category=1&academic_years=#{year}"
  end

  def district_url_for(district:, academic_year:)
    pages = %w[overview browse analyze]
    pages.each do |page|
      if request.fullpath.include? page
        return send("#{page}_link", district_slug: district.slug, school_slug: district.schools.alphabetic.first.slug,
                                    academic_year_range: academic_year.range)
      end
    end
  end

  def school_url_for(school:, academic_year:)
    pages = %w[overview browse analyze]
    pages.each do |page|
      if request.fullpath.include? page
        return send("#{page}_link", district_slug: school.district.slug, school_slug: school.slug,
                                    academic_year_range: academic_year.range)
      end
    end
  end

  def school_mapper(school)
    academic_year = latest_year(school)
    {
      name: school.name,
      district_id: school.district_id,
      url: district_school_overview_index_path(school.district, school,
                                               { year: academic_year.range })
    }
  end

  def latest_year(school)
    latest_response_rate = ResponseRate.where(school:)
                                       .where('meets_student_threshold = ? or meets_teacher_threshold = ?', true, true)
                                       .joins('inner join academic_years a on response_rates.academic_year_id=a.id')
                                       .order('a.range DESC').first
    academic_year = latest_response_rate.academic_year if latest_response_rate.present?

    academic_year || AcademicYear.order('range DESC').first
  end

  def link_weight(path:)
    active?(path:) ? 'weight-700' : 'weight-400'
  end

  private

  def overview_link(district_slug:, school_slug:, academic_year_range:)
    "/districts/#{district_slug}/schools/#{school_slug}/overview?year=#{academic_year_range}"
  end

  def analyze_link(district_slug:, school_slug:, academic_year_range:)
    "/districts/#{district_slug}/schools/#{school_slug}/analyze?year=#{academic_year_range}&academic_years=#{academic_year_range}"
  end

  def browse_link(district_slug:, school_slug:, academic_year_range:)
    "/districts/#{district_slug}/schools/#{school_slug}/browse/teachers-and-leadership?year=#{academic_year_range}"
  end

  def active?(path:)
    request.fullpath.include? path
  end
end
