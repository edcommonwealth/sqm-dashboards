require "fileutils"
class Cleaner
  attr_reader :input_filepath, :output_filepath, :log_filepath

  def initialize(input_filepath:, output_filepath:, log_filepath:)
    @input_filepath = input_filepath
    @output_filepath = output_filepath
    @log_filepath = log_filepath
    initialize_directories
  end

  def clean
    Dir.glob(Rails.root.join(input_filepath, "*.csv")).each do |filepath|
      puts filepath
      File.open(filepath) do |file|
        processed_data = process_raw_file(file:)
        processed_data in [headers, clean_csv, log_csv, data]
        return if data.empty?

        filename = filename(headers:, data:, filepath:)
        write_csv(data: clean_csv, output_filepath:, filename:)
        write_csv(data: log_csv, output_filepath: log_filepath, prefix: "removed.", filename:)
      end
    end
  end

  def filename(headers:, data:, filepath:)
    output = []
    survey_item_ids = headers.filter(&:present?).filter do |header|
                        header.start_with?("s-", "t-", "p-")
                      end.reject { |item| item.end_with? "-1" }
    survey_type = SurveyItem.survey_type(survey_item_ids:)
    range = data.first.academic_year.range

    districts = data.map do |row|
      row.district.short_name
    end.to_set.to_a

    schools = data.map do |row|
      row.school.name
    end.to_set

    part = filepath&.match(/[\b\s_.]+(part)[\W*_](?<label>[\w\d])/i)&.named_captures&.[]("label")&.upcase

    school_name = schools.first.parameterize

    output << districts.sort.join(".")
    output << school_name if schools.length == 1
    output << survey_type.to_s
    output << "Part-" + part unless part.nil?
    output << range.parameterize
    output << "csv"
    output.join(".")
  end

  def process_raw_file(file:)
    clean_csv = []
    log_csv = []
    data = []
    headers = CSV.parse(file.first).first

    # If this is a student survey
    # Make sure it includes a 'Grade' header
    is_student_survey = headers.filter(&:present?)
                               .filter { |header| header.start_with? "s-" }
                               .count > 0

    has_grade_header = headers.filter(&:present?).find { |header| header.match?(/grade/i) }.present?
    if is_student_survey && has_grade_header == false
      puts "could not find the Grade header.  Stopping execution"
      exit
    end

    duplicate_header = headers.detect { |header| headers.count(header) > 1 }
    unless duplicate_header.nil?
      puts "\n>>>>>>>>>>>>>>>>>>    Duplicate header found.  This will misalign column headings.  Please delete or rename the duplicate column: #{duplicate_header} \n>>>>>>>>>>>>>> \n"
      exit
    end

    headers = headers.to_set
    headers = headers.merge(Set.new(["Raw Income", "Income", "Raw ELL", "ELL", "Raw SpEd", "SpEd", "Progress Count",
                                     "Race", "Gender", "Raw Housing Status", "Housing Status", "Home Language", "Home Languages", "Declared Races of Children from Parents", "Declared Genders of Children from Parents"])).to_a
    filtered_headers = include_all_headers(headers:)
    filtered_headers = remove_unwanted_headers(headers: filtered_headers)
    log_headers = (filtered_headers + ["Valid Duration?", "Valid Progress?", "Valid Grade?",
                                       "Valid Standard Deviation?"]).flatten
    clean_csv << filtered_headers
    log_csv << log_headers

    all_survey_items = survey_items(headers:)

    file.lazy.each_slice(1000) do |lines|
      CSV.parse(lines.join, headers:).map do |row|
        values = SurveyItemValues.new(row:, headers:,
                                      survey_items: all_survey_items, schools:, academic_years:)
        unless values.valid_school?
          # puts "row #{values.response_id}: dese id :#{values.dese_id} : could not find school, skipping row for file #{file.path}"
          next
        end

        data << values
        values.valid? ? clean_csv << values.to_a : log_csv << (values.to_a << values.valid_duration?.to_s << values.valid_progress?.to_s << values.valid_grade?.to_s << values.valid_sd?.to_s)
      end
    end
    [headers, clean_csv, log_csv, data]
  end

  private

  def academic_years
    @academic_years ||= AcademicYear.all
  end

  def include_all_headers(headers:)
    alternates = headers.filter(&:present?)
                        .filter { |header| header.match?(/^[st]-\w*-\w*-1$/i) }
    alternates.each do |header|
      main = header.sub(/-1\z/, "")
      headers.push(main) unless headers.include?(main)
    end
    headers
  end

  def initialize_directories
    create_ouput_directory
    create_log_directory
  end

  def remove_unwanted_headers(headers:)
    headers.to_set.to_a.compact.reject do |item|
      item.start_with? "Q"
    end.reject { |header| header.match?(/^[stp]-\w*-\w*-1$/i) }
  end

  def write_csv(data:, output_filepath:, filename:, prefix: "")
    csv = CSV.generate do |csv|
      data.each do |row|
        csv << row
      end
    end
    File.write(output_filepath.join(prefix + filename), csv)
  end

  def schools
    @schools ||= School.by_dese_id
  end

  def genders
    @genders ||= Gender.by_qualtrics_code
  end

  def survey_items(headers:)
    survey_item_ids = headers
                      .filter(&:present?)
                      .filter { |header| header.start_with? "t-", "s-", "p-" }
    @survey_items ||= SurveyItem.where(survey_item_id: survey_item_ids)
  end

  def create_ouput_directory
    FileUtils.mkdir_p output_filepath
  end

  def create_log_directory
    FileUtils.mkdir_p log_filepath
  end
end
