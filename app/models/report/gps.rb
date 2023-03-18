module Report
  class Gps
    #     def self.to_csv
    #       headers = ['School', 'Pillar', 'Indicator', 'Period', 'HALS Category', 'Ref.', 'Score', 'Zone']
    #       attributes = %w[school_name pillar indicator period category measure_ids score zone]
    #       pillars = generate_pillars
    #       CSV.generate(headers: true) do |csv|
    #         csv << headers
    #         pillars.each do |gps|
    #           csv << attributes.map { |attr| gps.send(attr) }
    #         end
    #       end
    #     end

    #     def self.generate_pillars
    #       schools = School.all
    #       academic_years = AcademicYear.order(range: :desc).first(2)
    #       periods = %w[Current Previous]

    #       [].tap do |pillars|
    #         academic_years.zip(periods).each do |academic_year, period|
    #           schools.each do |school|
    #             INDICATORS.each do |indicator, measures|
    #               pillars << Pillar.new(school:, measures:, indicator:, period:, academic_year:)
    #             end
    #           end
    #         end
    #       end
    #     end

    #     INDICATORS =
    #       { "Teaching Environment": [Measure.includes(%i[subcategory admin_data_items]).find_by_measure_id('1A-iii'), Measure.includes(%i[subcategory admin_data_items]).find_by_measure_id('1B-ii')],
    #         "Safety": Subcategory.find_by_subcategory_id('2A').measures.includes(:admin_data_items),
    #         "Relationships": Subcategory.find_by_subcategory_id('2B').measures.includes(:admin_data_items),
    #         "Academic Orientation": Subcategory.find_by_subcategory_id('2C').measures.includes(:admin_data_items),
    #         "Facilities & Personnel": Subcategory.find_by_subcategory_id('3A').measures.includes(:admin_data_items),
    #         "Family-School Relationships": [Measure.includes(%i[subcategory admin_data_items]).find_by_measure_id('3C-i')],
    #         "Community Involvement & External Partners": [Measure.includes(%i[subcategory
    #                                                                           admin_data_items]).find_by_measure_id('3C-ii')],
    #         "Perception of Performance": Subcategory.find_by_subcategory_id('4A').measures.includes(:admin_data_items),
    #         "Student Commitment To Learning": Subcategory.find_by_subcategory_id('4B').measures.includes(:admin_data_items),
    #         "Critical Thinking": Subcategory.find_by_subcategory_id('4C').measures.includes(:admin_data_items),
    #         "College & Career Readiness": Subcategory.find_by_subcategory_id('4D').measures.includes(:admin_data_items) }
  end
end
