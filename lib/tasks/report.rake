namespace :report do
  desc "create a report of the scores for all subcategories"
  task subcategory: :environment do
    Report::Subcategory.create_report(filename: "ecp_subcategory_report.csv")
  end

  namespace :measure do
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

      measures = measure_ids.map { |measure_id| Measure.find_by_measure_id(measure_id) }

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
    task :create, [:school, :academic_year] => :environment do |_, args|
      school = School.find_by_name(args[:school])
      academic_year = AcademicYear.find_by_range(args[:academic_year])
      if school == nil
        puts "Invalid school name"
        bad = 1
      end
      if academic_year == nil
        puts "Invalid academic year"
        bad = 1
      end
      next if bad == 1
      Report::SurveyItem.create_item_report(school:, academic_year:)
      Report::SurveyItem.create_grade_report(school:, academic_year:)
    end
  end
end
