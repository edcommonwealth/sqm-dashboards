module HeaderHelper
  def link_to_overview(district:, school:, academic_year:)
    "/districts/#{district.slug}/schools/#{school.slug}/overview?year=#{academic_year.range}"
  end

  def link_to_browse(district:, school:, academic_year:)
    "/districts/#{district.slug}/schools/#{school.slug}/browse/teachers-and-leadership?year=#{academic_year.range}"
  end

  def district_url_for(district:, academic_year:)
    overview_link(district_slug: district.slug, school_slug: district.schools.alphabetic.first.slug,
                  academic_year_range: academic_year.range, uri_path: request.fullpath)
  end

  def school_url_for(school:, academic_year:)
    overview_link(district_slug: school.district.slug, school_slug: school.slug,
                  academic_year_range: academic_year.range, uri_path: request.fullpath)
  end

  def school_mapper(school)
    {
      name: school.name,
      district_id: school.district_id,
      url: district_school_overview_index_path(school.district, school, { year: AcademicYear.first.range })
    }
  end

  def link_weight(path:)
    active?(path:) ? 'weight-700' : 'weight-400'
  end

  private

  def overview_link(district_slug:, school_slug:, academic_year_range:, uri_path:)
    if uri_path.include?('overview')
      return "/districts/#{district_slug}/schools/#{school_slug}/overview?year=#{academic_year_range}"
    end

    "/districts/#{district_slug}/schools/#{school_slug}/browse/teachers-and-leadership?year=#{academic_year_range}"
  end

  def active?(path:)
    request.fullpath.include? path
  end
end
