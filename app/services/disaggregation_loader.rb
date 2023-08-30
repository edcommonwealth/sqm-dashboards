class DisaggregationLoader
  attr_reader :path

  def initialize(path:)
    @path = path
    initialize_directory
  end

  def load
    data = {}
    Dir.glob(Rails.root.join(path, "*.csv")).each do |filepath|
      puts filepath
      File.open(filepath) do |file|
        headers = CSV.parse(file.first).first

        file.lazy.each_slice(1000) do |lines|
          CSV.parse(lines.join, headers:).map do |row|
            values = DisaggregationRow.new(row:, headers:)
            data[[values.lasid, values.district, values.academic_year]] = values
          end
        end
      end
    end
    data
  end

  def initialize_directory
    FileUtils.mkdir_p(path)
  end
end

