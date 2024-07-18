# Report::SurveyItemResponse.create(schools: District.find_by_name("Lee Public Schools").schools, academic_years: AcademicYear.where(range: "2023-24 Spring"), filename: "test.csv")
module Report
  class SurveyItemResponse
    def self.create(schools:, academic_years:, filename:)
      data = []
      data << ["Response ID", "Race", "Gender", "Grade", "School ID", "District", "Academic Year", "Student Physical Safety",
               "Student Emotional Safety", "Student Sense of Belonging", "Student-Teacher Relationships", "Valuing of Learning", "Academic Challenge", "Content Specialists & Support Staff", "Cultural Responsiveness", "Engagement In School", "Appreciation For Diversity", "Civic Participation", "Perseverance & Determination", "Growth Mindset", "Participation In Creative & Performing Arts", "Valuing Creative & Performing Arts", "Social & Emotional Health"]

      mutex = Thread::Mutex.new
      pool_size = 2
      jobs = Queue.new
      schools.each { |school| jobs << school }

      workers = pool_size.times.map do
        Thread.new do
          while school = jobs.pop(true)
            academic_years.each do |academic_year|
              response_hash = {}
              survey_item_responses = ::SurveyItemResponse
                                      .includes([student: :races])
                                      .includes([school: :district])
                                      .includes([:gender])
                                      .where(school:, academic_year:, survey_item: student_survey_items_with_sufficient_responses(school:,
                                                                                                                                  academic_year:))
              survey_item_responses.each do |sir|
                response_hash[sir.response_id] = if response_hash[sir.response_id].nil?
                                                   [sir]
                                                 else
                                                   response_hash[sir.response_id] << sir
                                                 end
              end
              respondents = Respondent.by_school_and_year(school:, academic_year:)
              next if respondents.nil?

              response_hash.each do |_key, responses|
                mutex.synchronize do
                  row = []
                  info = responses.first
                  response_id = info.response_id
                  row << [response_id,
                          info.student.races.map { |race| race.designation }.join("\n"),
                          info.gender.designation,
                          info.grade,
                          info.school.name,
                          info.school.district.name,
                          academic_year.range,
                          average_for_measure("2A-i", responses),
                          average_for_measure("2A-ii", responses),
                          average_for_measure("2B-i", responses),
                          average_for_measure("2B-ii", responses),
                          average_for_measure("2C-i", responses),
                          average_for_measure("2C-ii", responses),
                          average_for_measure("3A-ii", responses),
                          average_for_measure("3B-ii", responses),
                          average_for_measure("4B-i", responses),
                          average_for_measure("5A-i", responses),
                          average_for_measure("5A-ii", responses),
                          average_for_measure("5C-i", responses),
                          average_for_measure("5C-ii", responses),
                          average_for_measure("5D-i", responses)]

                  data.concat(row)
                end
              end
            end
          end
        rescue ThreadError
        end
      end

      workers.each(&:join)
      FileUtils.mkdir_p Rails.root.join("tmp", "reports")
      filepath = Rails.root.join("tmp", "reports", filename)
      write_csv(data:, filepath:)
      data
    end

    def self.average_for_measure(measure_id, responses)
      selected_responses = responses.select do |response|
        student_survey_items_for_measure(measure_id).include?(response.survey_item_id)
      end

      average = selected_responses.map(&:likert_score).average
      average = average.round(2) unless average.nil?
      average = "" if average.nan?
      average
    end

    def self.student_survey_items_for_measure(measure_id)
      @student_survey_items_for_measure ||= Hash.new do |memo, measure_id|
        memo[measure_id] = ::Measure.find_by_measure_id(measure_id).student_survey_items.map(&:id)
      end
      @student_survey_items_for_measure[measure_id]
    end

    def self.write_csv(data:, filepath:)
      csv = CSV.generate do |csv|
        data.each do |row|
          csv << row
        end
      end
      File.write(filepath, csv)
    end

    def self.student_survey_items_with_sufficient_responses(school:, academic_year:)
      @student_survey_items_with_sufficient_responses ||= Hash.new do |memo, (school, academic_year)|
        memo[[school, academic_year]] = ::SurveyItem.where(id: ::SurveyItem.joins("inner join survey_item_responses on survey_item_responses.survey_item_id = survey_items.id")
                                        .student_survey_items
                                        .where("survey_item_responses.school": school,
                                               "survey_item_responses.academic_year": academic_year,
                                               "survey_item_responses.survey_item_id": ::SurveyItem.student_survey_items,
                                               "survey_item_responses.grade": school.grades(academic_year:))
                                        .group("survey_items.id")
                                        .having("count(*) >= 10")
                                        .count.keys)
      end
      @student_survey_items_with_sufficient_responses[[school, academic_year]]
    end
  end
end
