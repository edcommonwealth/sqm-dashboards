
class SkippedQuestionsLoader
  attr_reader :output_rows, :counts, :avg

  def initialize(survey_items)
    @headers = ['Academic Year', 'Survey Item','Prompt','average of Percentage_diff']
    @output_rows = []
    @counts = {}
    @avg = 0
    @temp = 0
    @count_response_grades_not_in_grades = 0
    @survey_items = survey_items
  end

  def generate(survey_type)
    School.all.each do |sc|
      AcademicYear.all.each do |ay|
        calculate_averages(sc, ay, survey_type)
      end
    end
    generate_csv(survey_type)
end


  private

  def calculate_averages(sc, ay, survey_type)
    grades = get_grades(sc, ay)
    threshold = Respondent.where(school: sc, academic_year: ay).pluck(:total_students)
    sum = 0
    nof_si = 0
    @survey_items.each do |si|
      c = SurveyItemResponse.where(school: sc, academic_year: ay, survey_item: si,grade: grades).group(:school_id).count
      if threshold.any? 
        if c.any? && ((c.values.first >= 10 || c.values.first > threshold.first/4) || survey_type=='teacher_survey_items')
          @counts[[sc.id, ay.id, si.id]] = c
          sum+=c.values.first
          nof_si+=1
        end
      end
    end

    @avg = sum.to_f/ nof_si
    calculate_percentage_diff(sc, ay)
  end

  def get_grades(sc, ay)
    if Respondent.where(school: sc,academic_year:ay).any?
      grades_count=Respondent.where(school:sc,academic_year:ay).first.counts_by_grade
      grades= grades_count.keys
    else 
      grades=[]
    end
    grades
  end

  def calculate_percentage_diff(sc, ay)
    @counts.each do |key, value|
      if key[0] == sc.id && key[1] == ay.id
        count = value.values.first
        percentage_diff = ((count-@avg) / @avg) * 100
        @counts[key] = { count: count, percentage_diff: percentage_diff } 
      end
    end
  end

  def generate_csv(survey_type)
    averages = calculate_average_percentage_diff
    averages.each do |key, value|
      @output_rows << [AcademicYear.where(id:key[0]).pluck(:range) , SurveyItem.where(id:key[1]).pluck(:survey_item_id), SurveyItem.where(id:key[1]).pluck(:prompt),value]
    end
    
    file = File.new("#{survey_type}_most_skipped_questions.csv", 'w')
    CSV.open(file, 'w', write_headers: true, headers: @headers) do |csv|
      @output_rows.each do |row|
        csv << row
      end
    end
    
    file.close
  end

  def calculate_average_percentage_diff
    average={}
    @counts.each do |key, value|
      average[[key[1],key[2]]] ||= []  
      average[[key[1],key[2]]] << value[:percentage_diff]
    end
    averages = {}
    average.each do |key, values|
      averages[key] = values.sum / values.size.to_f
    end
    averages
  end
end