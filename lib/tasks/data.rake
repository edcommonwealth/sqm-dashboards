require 'csv'

namespace :data do
  desc "Load in all data"
  task load: :environment do
    # return if School.count > 0
    # Rake::Task["db:seed"].invoke
    Rake::Task["data:load_categories"].invoke
    Rake::Task["data:load_questions"].invoke
    # Rake::Task["data:load_student_responses"].invoke
  end

  desc 'Load in category data'
  task load_categories: :environment do
    measures = JSON.parse(File.read(File.expand_path('../../../data/measures.json', __FILE__)))
    measures.each_with_index do |measure, index|
      category = Category.create(
        name: measure['title'],
        blurb: measure['blurb'],
        description: measure['text'],
        external_id: index + 1
      )

      measure['sub'].keys.sort.each do |key|
        subinfo = measure['sub'][key]
        subcategory = category.child_categories.create(
          name: subinfo['title'],
          blurb: subinfo['blurb'],
          description: subinfo['text'],
          external_id: key
        )

        subinfo['measures'].keys.sort.each do |subinfo_key|
          subsubinfo = subinfo['measures'][subinfo_key]
          subsubcategory = subcategory.child_categories.create(
            name: subsubinfo['title'],
            blurb: subsubinfo['blurb'],
            description: subsubinfo['text'],
            external_id: subinfo_key
          )

          # if subsubinfo['nonlikert'].present?
          #   subsubinfo['nonlikert'].each do |nonlikert_info|
          #     next unless nonlikert_info['likert'].present?
          #     nonlikert = subsubcategory.child_measures.create(
          #       name: nonlikert_info['title'],
          #       description: nonlikert_info['benchmark_explanation'],
          #       benchmark: nonlikert_info['benchmark']
          #     )
          #
          #    name_map = {
          #       "argenziano": "dr-albert-f-argenziano-school-at-lincoln-park",
          #       "healey": "arthur-d-healey-school",
          #       "brown": "benjamin-g-brown-school",
          #       "east": "east-somerville-community-school",
          #       "kennedy": "john-f-kennedy-elementary-school",
          #       "somervillehigh": "somerville-high-school",
          #       "west": "west-somerville-neighborhood-school",
          #       "winter": "winter-hill-community-innovation-school"
          #     }
          #
          #     nonlikert_info['likert'].each do |key, likert|
          #       school_name = name_map[key.to_sym]
          #       next if school_name.nil?
          #       school = School.friendly.find(school_name)
          #       nonlikert.measurements.create(school: school, likert: likert, nonlikert: nonlikert_info['values'][key])
          #     end
          #   end
          # end
        end
      end
    end
  end

  desc 'Load in question data'
  task load_questions: :environment do
    variations = [
      'homeroom',
      'English',
      'Math',
      'Science',
      'Social Studies'
    ]

    questions = JSON.parse(File.read(File.expand_path('../../../data/questions.json', __FILE__)))
    questions.each do |question|
      category = nil
      question['category'].split('-').each do |external_id|
        categories = category.present? ? category.child_categories : Category
        category = categories.where(external_id: external_id).first
        if category.nil?
          puts 'NOTHING'
          puts external_id
          puts categories.inspect
        end
      end
      question_text = question['text'].gsub(/[[:space:]]/, ' ').strip
      if question_text.index('*').nil?
        category.questions.create(
          text: question_text,
          option1: question['answers'][0],
          option2: question['answers'][1],
          option3: question['answers'][2],
          option4: question['answers'][3],
          option5: question['answers'][4]
        )
      else
        variations.each do |variation|
          category.questions.create(
            text: question_text.gsub('.*', variation),
            option1: question['answers'][0],
            option2: question['answers'][1],
            option3: question['answers'][2],
            option4: question['answers'][3],
            option5: question['answers'][4]
          )
        end
      end
    end
  end

  desc 'Load in student and teacher responses'
  task load_student_responses: :environment do
    ENV['BULK_PROCESS'] = 'true'
    answer_dictionary = {
      'Slightly': 'Somewhat'
    }

    unknown_schools = {}
    missing_questions = {}
    bad_answers = {}
    year = '2016'
    ['student_responses', 'teacher_responses'].each do |file|
      source = Measurement.sources[file.split('_')[0]]
      csv_string = File.read(File.expand_path("../../../data/#{file}_#{year}.csv", __FILE__))
      csv = CSV.parse(csv_string, :headers => true)
      csv.each do |row|
        school_name = row['What school do you go to?']
        school_name = row['What school do you work at'] if school_name.nil?
        school = School.find_by_name(school_name)
        if school.nil?
          next if unknown_schools[school_name]
          puts "Unable to find school: #{school_name}"
          unknown_schools[school_name] = true
          next
        end

        row.each do |key, value|
          next if value.nil? or key.nil?
          key = key.gsub(/[[:space:]]/, ' ').strip
          value = value.gsub(/[[:space:]]/, ' ').strip.downcase
          question = Question.find_by_text(key)
          if question.nil?
            next if missing_questions[key]
            puts "Unable to find question: #{key}"
            missing_questions[key] = true
            next
          end

          answers = YAML::load(question.answers).collect { |a| a.gsub(/[[:space:]]/, ' ').strip.downcase }
          answerIndex = answers.index(value)
          answer_dictionary.each do |k, v|
            break if answerIndex.present?
            answerIndex = answers.index(value.gsub(k.to_s, v.to_s)) || answers.index(value.gsub(v.to_s, k.to_s))
          end

          if answerIndex.nil?
            next if bad_answers[key]
            puts "Unable to find answer: #{key} = #{value} - #{answers.inspect}"
            bad_answers[key] = true
            next
          end

          question.measurements.create(school: school, likert: answerIndex + 1, source: source)
        end
      end
    end
    ENV.delete('BULK_PROCESS')

    SchoolMeasure.all.each { |sm| sm.calculate_measurements }
  end
end
