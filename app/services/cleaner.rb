require 'fileutils'
class Cleaner
  attr_reader :input_filepath, :output_filepath, :log_filepath, :disaggregation_filepath

  def initialize(input_filepath:, output_filepath:, log_filepath:, disaggregation_filepath:)
    @input_filepath = input_filepath
    @output_filepath = output_filepath
    @log_filepath = log_filepath
    @disaggregation_filepath = disaggregation_filepath
    initialize_directories
  end

  def clean
    Dir.glob(Rails.root.join(input_filepath, '*.csv')).each do |filepath|
      puts filepath
      File.open(filepath) do |file|
        processed_data = process_raw_file(file:, disaggregation_data:)
        processed_data in [headers, clean_csv, log_csv, data]
        return if data.empty?

        filename = filename(headers:, data:)
        write_csv(data: clean_csv, output_filepath:, filename:)
        write_csv(data: log_csv, output_filepath: log_filepath, prefix: 'removed.', filename:)
      end
    end
  end

  def disaggregation_data
    @disaggregation_data ||= DisaggregationLoader.new(path: disaggregation_filepath).load
  end

  def filename(headers:, data:)
    survey_item_ids = headers.filter(&:present?).filter do |header|
                        header.start_with?('s-', 't-')
                      end.reject { |item| item.end_with? '-1' }
    survey_type = SurveyItem.survey_type(survey_item_ids:)
    range = data.first.academic_year.range

    districts = data.map do |row|
      row.district.short_name
    end.to_set.to_a

    districts.join('.').to_s + '.' + survey_type.to_s + '.' + range + '.csv'
  end

  def process_raw_file(file:, disaggregation_data:)
    clean_csv = []
    log_csv = []
    data = []

    headers = (CSV.parse(file.first).first << 'Raw Income') << 'Income'
    filtered_headers = remove_unwanted_headers(headers:)
    log_headers = (filtered_headers + ['Valid Duration?', 'Valid Progress?', 'Valid Grade?',
                                       'Valid Standard Deviation?']).flatten

    clean_csv << filtered_headers
    log_csv << log_headers

    all_survey_items = survey_items(headers:)

    file.lazy.each_slice(1000) do |lines|
      CSV.parse(lines.join, headers:).map do |row|
        values = SurveyItemValues.new(row:, headers:, genders:,
                                      survey_items: all_survey_items, schools:, disaggregation_data:)
        next unless values.valid_school?

        data << values
        values.valid? ? clean_csv << values.to_a : log_csv << (values.to_a << values.valid_duration?.to_s << values.valid_progress?.to_s << values.valid_grade?.to_s << values.valid_sd?.to_s)
      end
    end
    [headers, clean_csv, log_csv, data]
  end

  private

  def initialize_directories
    create_ouput_directory
    create_log_directory
  end

  def remove_unwanted_headers(headers:)
    headers.to_set.to_a.compact.reject do |item|
      item.start_with? 'Q'
    end.reject { |item| item.end_with? '-1' }
  end

  def write_csv(data:, output_filepath:, filename:, prefix: '')
    csv = CSV.generate do |csv|
      data.each do |row|
        csv << row
      end
    end
    File.write(output_filepath.join(prefix + filename), csv)
  end

  def schools
    @schools ||= School.school_hash
  end

  def genders
    @genders ||= Gender.gender_hash
  end

  def survey_items(headers:)
    survey_item_ids = headers
                      .filter(&:present?)
                      .filter { |header| header.start_with? 't-', 's-' }
    @survey_items ||= SurveyItem.where(survey_item_id: survey_item_ids)
  end

  def create_ouput_directory
    FileUtils.mkdir_p output_filepath
  end

  def create_log_directory
    FileUtils.mkdir_p log_filepath
  end
end
