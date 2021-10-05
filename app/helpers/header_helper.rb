module HeaderHelper

  def link_to_dashboard(district:, school:, academic_year:)
    "/districts/#{district.slug}/schools/#{school.slug}/dashboard?year=#{academic_year.range}"
  end

  def link_to_browse(district:, school:, academic_year:)
    "/districts/#{district.slug}/schools/#{school.slug}/browse/teachers-and-leadership?year=#{academic_year.range}"
  end

  def district_url_for(district:, academic_year:)
    dashboard_link(district_slug: district.slug, school_slug: district.schools.alphabetic.first.slug, academic_year_range: academic_year.range, uri_path: request.fullpath)
  end

  def school_url_for(school:, academic_year:)
    dashboard_link(district_slug: school.district.slug, school_slug: school.slug, academic_year_range: academic_year.range, uri_path: request.fullpath)
  end

  private

  def dashboard_link(district_slug:, school_slug:, academic_year_range:, uri_path:)
    if uri_path.include?("dashboard")
      return "/districts/#{district_slug}/schools/#{school_slug}/dashboard?year=#{academic_year_range}"
    end
    "/districts/#{district_slug}/schools/#{school_slug}/browse/teachers-and-leadership?year=#{academic_year_range}"
  end

end
