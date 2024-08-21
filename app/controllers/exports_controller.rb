class ExportsController < ApplicationController
  protect_from_forgery with: :exception, prepend: true
  before_action :authenticate_admin

  def index
    @presenter = ExportsPresenter.new(params:)
    @districts = @presenter.districts
    @selected_district_id = @presenter.selected_district_id
    @academic_years = @presenter.academic_years
    @selected_academic_years = @presenter.selected_academic_years

    @schools = @presenter.schools
    @selected_school = @presenter.selected_school

    @schools_grouped_by = @presenter.schools_grouped_by

    @reports = reports.keys
    @student_survey_types = student_survey_types.keys
    @student_survey_type = params[:student_survey_type]
  end

  def show
    respond_to do |format|
      format.html
      format.csv do
        year_params = params.select { |param| param.start_with?("academic_year") }.values
        academic_years = AcademicYear.where(range: year_params)
        group = params["school_group"]

        if group == "district"
          district_id ||= params[:district]&.to_i if params[:district].present?
          district = District.find(district_id) if district_id.present?
          district ||= District.first
          schools = district.schools
        elsif group == "school"
          schools = [School.find_by_name(params["school"])]
        elsif group == "all"
          schools = School.all
        end

        report = params[:report]

        if ["Survey Item - By Item", "Survey Item - By Grade", "Survey Entries - by Measure"].include?(report)
          use_student_survey_items = student_survey_types[params[:student_survey_type]]
          reports[report].call(schools, academic_years, use_student_survey_items)
        else
          reports[report].call(schools, academic_years)
        end
      end
    end
  end

  private

  def schools_for_group(group)
    if group == "district"
      district_id ||= params[:district]&.to_i if params[:district].present?
      district = District.find(district_id) if district_id.present?
      district ||= District.first
      district.schools
    elsif group == "school"
      [School.find_by_name(params["school"])]
    elsif group == "all"
      School.all
    end
  end

  def reports
    { "Subcategory - School & District" => lambda { |schools, academic_years|
                                             data = Report::Subcategory.to_csv(schools:, academic_years:)
                                             send_data data, disposition: "attachment",
                                                             filename: "subcategory_#{Date.today}.csv"
                                           },
      "Measure - District only" => lambda { |schools, academic_years|
                                     data = Report::MeasureSummary.to_csv(schools:, academic_years:,
                                                                          measures: Measure.all)
                                     send_data data, disposition: "attachment",
                                                     filename: "measure_summary_#{Date.today}.csv"
                                   },
      "Measure - School & District" => lambda { |schools, academic_years|
                                         data = Report::Measure.to_csv(schools:, academic_years:,
                                                                       measures: ::Measure.all)
                                         send_data data, disposition: "attachment",
                                                         filename: "measure_detailed_#{Date.today}.csv"
                                       },
      "Beyond Learning Loss" => lambda { |schools, academic_years|
                                  measure_ids = %w[2A-i 2A-ii 2B-i 2B-ii 2C-i 2C-ii 4B-i 5B-i 5B-ii 5D-i]
                                  scales = measure_ids.map do |measure_id|
                                    Measure.find_by_measure_id(measure_id)
                                  end.map(&:scales).flatten.compact
                                  data = Report::BeyondLearningLoss.to_csv(schools:, academic_years:, scales:)
                                  send_data data, disposition: "attachment",
                                                  filename: "beyond_learning_loss_#{Date.today}.csv"
                                },
      "Survey Item - By Item" => lambda { |schools, academic_years, use_student_survey_items|
                                   data = Report::SurveyItemByItem.to_csv(schools:, academic_years:,
                                                                          use_student_survey_items:)
                                   send_data data, disposition: "attachment",
                                                   filename: "survey_item_by_item_#{Date.today}.csv"
                                 },
      "Survey Item - By Grade" => lambda { |schools, academic_years, use_student_survey_items|
                                    data = Report::SurveyItemByGrade.to_csv(schools:, academic_years:,
                                                                            use_student_survey_items:)
                                    send_data data,
                                              disposition: "attachment", filename: "survey_item_by_grade_#{Date.today}.csv"
                                  },

      "Survey Entries - by Measure" => lambda { |schools, academic_years, use_student_survey_items|
        data = Report::SurveyItemResponse.to_csv(schools:, academic_years:, use_student_survey_items:)
        send_data data, disposition: "attachment", filename: "survey_item_response_#{Date.today}.csv"
      } }
  end

  def student_survey_types
    {
      "All Student Survey Items" => ::SurveyItem.student_survey_items.pluck(:id),
      "Standard" => ::SurveyItem.standard_survey_items.pluck(:id),
      "Short Form" => ::SurveyItem.short_form_survey_items.pluck(:id),
      "Early Education" => ::SurveyItem.early_education_survey_items.pluck(:id)
    }
  end

  def authenticate_admin
    authenticate("admin", ENV.fetch("ADMIN_PASS"))
  end

  def authenticate(username, password)
    authenticate_or_request_with_http_basic do |u, p|
      u == username && p == password
    end
  end
end
