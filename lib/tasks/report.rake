namespace :report do
  desc "create a report of the scores for all subcategories"
  task subcategory: :environment do
    Report::Subcategory.create_report(filename: "ecp_subcategory_report.csv")
  end

  namespace :measure do
    task :district, %i[district ay] => :environment do |_, args|
      #  measure_ids = %w[
      #   1A-i
      #   1A-ii
      #   1A-iii
      #   1B-i
      #   1B-ii
      #   2A-i
      #   2A-ii
      #   2B-i
      #   2B-ii
      #   2C-i
      #   2C-ii
      #   3A-i
      #   3A-ii
      #   3B-i
      #   3B-ii
      #   3B-iii
      #   3C-i
      #   3C-ii
      #   4A-i
      #   4A-ii
      #   4B-i
      #   4B-ii
      #   4C-i
      #   4D-i
      #   4D-ii
      #   5A-i
      #   5A-ii
      #   5B-i
      #   5B-ii
      #   5C-i
      #   5C-ii
      #   5D-i
      #   5D-ii
      # ]
      # measures = measure_ids.map { |measure_id| Measure.find_by_measure_id(measure_id) }

      district = District.find_by_name args[:district]
      academic_years = AcademicYear.where(range: args[:ay])
      if district.nil?
        puts "Invalid district name"
        bad = true
      end
      if academic_years.nil?
        puts "Invalid academic year"
        bad = true
      end
      next if bad

      Report::Measure.create_report(
        schools: School.where(district:),
        academic_years:,
        # measures:,
        filename: "measure_report_" + district.slug + ".csv"
      )
    end

    task sqm: :environment do
      measure_ids = %w[
        1A-i
        1A-ii
        1A-iii
        1B-i
        1B-ii
        2A-i
        2A-ii
        2B-i
        2B-ii
        2C-i
        2C-ii
        3A-i
        3A-ii
        3B-i
        3B-ii
        3B-iii
        3C-i
        3C-ii
        4A-i
        4A-ii
        4B-i
        4B-ii
        4C-i
        4D-i
        4D-ii
        5A-i
        5A-ii
        5B-i
        5B-ii
        5C-i
        5C-ii
        5D-i
        5D-ii
      ]

      measures = measure_ids.map { |measure_id| Measure.find_by_measure_id(measure_id) }.reject(&:nil?)

      Report::Measure.create_report(filename: "measure_report.csv", measures:)
    end
  end

  namespace :scale do
    task bll: :environment do
      measure_ids = %w[
        2A-i
        2A-ii
        2B-i
        2B-ii
        2C-i
        2C-ii
        4B-i
        5B-i
        5B-ii
        5D-i
      ]

      measures = measure_ids.map { |measure_id| Measure.find_by_measure_id(measure_id) }
      scales = []
      measures.each { |measure| scales << measure.scales }
      scales = scales.flatten.compact

      Report::BeyondLearningLoss.create_report(filename: "bll_report.csv", scales:)
    end
  end

  namespace :survey_item do
    task :create, %i[school academic_year] => :environment do |_, args|
      school = School.find_by_name(args[:school])
      academic_year = AcademicYear.find_by_range(args[:academic_year])
      if school.nil?
        puts "Invalid school name"
        bad = 1
      end
      if academic_year.nil?
        puts "Invalid academic year"
        bad = 1
      end
      next if bad == 1

      Report::SurveyItem.create_item_report(school:, academic_year:,
                                            filename: "survey_item_report_" + school.slug + "_" + academic_year.range + "_by_item.csv")
      Report::SurveyItem.create_grade_report(school:, academic_year:,
                                             filename: "survey_item_report_" + school.slug + "_" + academic_year.range + "_by_grade.csv")
    end
  end

  namespace :survey_item do
    task :district, %i[district academic_year] => :environment do |_, args|
      district = District.find_by_name(args[:district])
      if district.nil?
        puts "Invalid district name"
        bad = 1
      end
      academic_year = AcademicYear.find_by_range(args[:academic_year])
      if academic_year.nil?
        puts "Invalid academic year"
        bad = 1
      end
      next if bad == 1

      schools = district.schools
      schools.each do |school|
        Report::SurveyItem.create_item_report(school:, academic_year:,
                                              filename: "survey_item_report_" + school.slug + "_" + academic_year.range + "_by_item.csv")
        Report::SurveyItem.create_grade_report(school:, academic_year:,
                                               filename: "survey_item_report_" + school.slug + "_" + academic_year.range + "_by_grade.csv")
      end
    end
  end
end
