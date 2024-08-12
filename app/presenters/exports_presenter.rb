class ExportsPresenter
  attr_reader :districts, :selected_district_id, :academic_years, :selected_academic_years, :schools, :selected_school,
              :reports, :schools_grouped_by, :show_student_survey_types

  def initialize(params:)
    @districts = District.all.map { |district| [district.name, district.id] }
    @selected_district_id ||= params[:district]&.to_i if params[:district].present?
    @selected_district_id ||= @districts.first
    @academic_years = AcademicYear.all.order(range: :ASC)
    @selected_academic_years = params.select { |param| param.start_with?("academic_year") }.values

    @schools = School.all.order(name: :ASC)
    @selected_school ||= School.find_by_name(params[:school])
    @selected_school ||= @schools.first

    @schools_grouped_by = params["school_group"]
    @show_student_survey_types = params[:report] == "Survey Item - By Item"
  end
end
