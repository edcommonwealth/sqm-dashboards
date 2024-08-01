class ExportsController < ApplicationController
  protect_from_forgery with: :exception, prepend: true
  before_action :authenticate_admin

  def index
    @districts = District.all.map { |district| [district.name, district.id] }
    @selected_district_id ||= params[:district]&.to_i if params[:district].present?
    @selected_district_id ||= @districts.first
    @academic_years = AcademicYear.all.order(range: :ASC)
    @selected_academic_years = params.select { |param| param.start_with?("academic_year") }.values

    @schools = School.all.order(name: :ASC)
    @selected_school ||= School.find_by_name(params[:school])
    @selected_school ||= @schools.first

    @reports = reports.keys
    @schools_grouped_by = params["school_group"]
  end

  def show
    respond_to do |format|
      format.html
      format.csv do
        year_params = params.select { |param| param.start_with?("academic_year") }.values
        academic_years = AcademicYear.where(range: year_params)

        if params["school_group"] == "district"
          district_id ||= params[:district]&.to_i if params[:district].present?
          district = District.find(district_id) if district_id.present?
          district ||= District.first
          schools = district.schools
        else
          schools = [School.find_by_name(params["school"])]
        end

        reports[params[:report]].call(schools, academic_years)
      end
    end
  end

  private

  def reports
    { "Subcategory" => lambda { |schools, academic_years|
                         data = Report::Subcategory.to_csv(schools:, academic_years:)
                         send_data data, disposition: "attachment", filename: "subcategory_#{Date.today}.csv"
                       },
      "Measure Summary" => lambda { |schools, academic_years|
                             data = Report::MeasureSummary.to_csv(schools:, academic_years:, measures: Measure.all)
                             send_data data, disposition: "attachment",
                                             filename: "measure_summary_#{Date.today}.csv"
                           },
      "Measure Detailed" => lambda { |schools, academic_years|
                              data = Report::Measure.to_csv(schools:, academic_years:, measures: ::Measure.all)
                              send_data data, disposition: "attachment", filename: "measure_detailed_#{Date.today}.csv"
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
      "Survey Item - By Item" => lambda { |schools, academic_years|
                                   data = Report::SurveyItemByItem.to_csv(schools:, academic_years:,
                                                                          use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
                                   send_data data, disposition: "attachment",
                                                   filename: "survey_item_by_item_#{Date.today}.csv"
                                 },
      "Survey Item - By Grade" => lambda { |schools, academic_years|
                                    data = Report::SurveyItemByGrade.to_csv(schools:, academic_years:,
                                                                            use_student_survey_items: ::SurveyItem.student_survey_items.pluck(:id))
                                    send_data data,
                                              disposition: "attachment", filename: "survey_item_by_grade_#{Date.today}.csv"
                                  },
      "Survey Item Response" => lambda { |schools, academic_years|
        data = Report::SurveyItemResponse.to_csv(schools:, academic_years:)
        send_data data, disposition: "attachment", filename: "survey_item_response_#{Date.today}.csv"
      } }
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
