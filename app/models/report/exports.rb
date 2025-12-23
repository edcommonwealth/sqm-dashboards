module Report
  class Exports
    def self.create(districts: ::District.all, academic_years: ::AcademicYear.all, use_student_survey_items: ::SurveyItem.student_survey_items.map(&:id))
      # academic_years = ::AcademicYear.all
      # districts = ::District.all
      # use_student_survey_items = ::SurveyItem.student_survey_items.map(&:id)
      schools = districts.flat_map(&:schools)

      reports = {
        "Subcategory by School & District" => lambda { |schools, academic_years|
          Report::Subcategory.to_csv(schools:, academic_years:, subcategories: ::Subcategory.all)
        },
        "Measure by District only" => lambda { |schools, academic_years|
          Report::MeasureSummary.to_csv(schools:, academic_years:, measures: ::Measure.all)
        },
        "Measure by School & District" => lambda { |schools, academic_years|
          Report::Measure.to_csv(schools:, academic_years:,
                                 measures: ::Measure.all)
        },
        "Survey Item by Item" => lambda { |schools, academic_years|
          Report::SurveyItemByItem.to_csv(schools:, academic_years:)
        },
        "Survey Item by Grade" => lambda { |schools, academic_years|
          Report::SurveyItemByGrade.to_csv(schools:, academic_years:,
                                           use_student_survey_items:)
        },
        "Survey Entries by Measure" => lambda { |schools, academic_years|
          Report::SurveyItemResponse.to_csv(schools:, academic_years:, use_student_survey_items:)
        }
      }

      reports.each do |report_name, runner|
        report_name = report_name.gsub(" ", "_").downcase

        academic_years.each do |academic_year|
          districts.each do |district|
            # Each year
            threads = []
            threads << Thread.new do
              response_count = ::SurveyItemResponse.where(school: district.schools, academic_year: academic_year).count
              if response_count > 100
                schools = district.schools
                report_name = report_name.gsub(" ", "_").downcase

                ::FileUtils.mkdir_p ::Rails.root.join("tmp", "exports", report_name, academic_year.range, district.name)

                filename = "#{report_name}_#{academic_year.range}_#{district.name}.csv"
                filepath = Rails.root.join("tmp", "exports", report_name, academic_year.range, district.name, filename)
                csv = runner.call(schools, [academic_year])

                File.write(filepath, csv)
              end
            end
            threads.each(&:join)
            GC.start
          end
          # All districts
          response_count = ::SurveyItemResponse.where(school: districts.flat_map(&:schools), academic_year: academic_year).count
          next unless response_count > 100

          threads = []
          threads << Thread.new do
            ::FileUtils.mkdir_p ::Rails.root.join("tmp", "exports", report_name, academic_year.range, "all_districts")

            filename = "#{report_name}_all_districts.csv"
            filepath = Rails.root.join("tmp", "exports", report_name, academic_year.range, "all_districts", filename)
            csv = runner.call(districts.flat_map(&:schools), [academic_year])

            File.write(filepath, csv)
          end
          threads.each(&:join)
          GC.start
        end

        districts.each do |district|
          #   # All years for each district
          threads = []
          threads << Thread.new do
            response_count = ::SurveyItemResponse.where(school: district.schools, academic_year: academic_years).count
            next unless response_count > 100

            ::FileUtils.mkdir_p ::Rails.root.join("tmp", "exports", report_name, "all_years", district.name)

            filename = "#{report_name}_all_years_#{district.name}.csv"
            filepath = Rails.root.join("tmp", "exports", report_name, "all_years", district.name, filename)
            csv = runner.call(district.schools, academic_years)

            File.write(filepath, csv)
            GC.start
          end
          threads.each(&:join)
          GC.start
        end
      end
    end
  end
end
