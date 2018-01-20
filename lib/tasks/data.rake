# PSQL: /Applications/Postgres.app/Contents/Versions/9.5/bin/psql -h localhost


require 'csv'

namespace :data do
  desc "Load in all data"
  task load: :environment do
    # return if School.count > 0
    Rake::Task["data:load_categories"].invoke
    Rake::Task["data:load_questions"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["data:load_responses"].invoke
  end

  desc 'Load in category data'
  task load_categories: :environment do
    measures = JSON.parse(File.read(File.expand_path('../../../data/measures.json', __FILE__)))
    measures.each_with_index do |measure, index|
      category = Category.create_with(
        blurb: measure['blurb'],
        description: measure['text'],
        external_id: measure['id'] || index + 1
      ).find_or_create_by(name: measure['title'])

      measure['sub'].keys.sort.each do |key|
        subinfo = measure['sub'][key]
        subcategory = category.child_categories.create_with(
          blurb: subinfo['blurb'],
          description: subinfo['text'],
          external_id: key
        ).find_or_create_by(name: subinfo['title'])

        subinfo['measures'].keys.sort.each do |subinfo_key|
          subsubinfo = subinfo['measures'][subinfo_key]
          subsubcategory = subcategory.child_categories.create_with(
            blurb: subsubinfo['blurb'],
            description: subsubinfo['text'],
            external_id: subinfo_key
          ).find_or_create_by(name: subsubinfo['title'])

          if subsubinfo['nonlikert'].present?
            subsubinfo['nonlikert'].each do |nonlikert_info|
              puts("NONLIKERT FOUND: #{nonlikert_info['title']}")
              nonlikert = subsubcategory.child_categories.create_with(
                benchmark_description: nonlikert_info['benchmark_explanation'],
                benchmark: nonlikert_info['benchmark']
              ).find_or_create_by(name: nonlikert_info['title'])
            end
          end
        end
      end
    end
  end

  desc 'Load in question data'
  task load_questions: :environment do
    variations = [
      '[Field-MathTeacher][Field-ScienceTeacher][Field-EnglishTeacher][Field-SocialTeacher]',
      'teacher'
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
      if question_text.index('.* teacher').nil?
        category.questions.create(
          text: question_text,
          option1: question['answers'][0],
          option2: question['answers'][1],
          option3: question['answers'][2],
          option4: question['answers'][3],
          option5: question['answers'][4],
          for_recipient_students: question['child'].present?
        )
      else
        variations.each do |variation|
          category.questions.create(
            text: question_text.gsub('.* teacher', variation),
            option1: question['answers'][0],
            option2: question['answers'][1],
            option3: question['answers'][2],
            option4: question['answers'][3],
            option5: question['answers'][4],
            for_recipient_students: question['child'].present?
          )
        end
      end
    end
  end

  desc 'Load in student and teacher responses'
  task load_responses: :environment do
    ENV['BULK_PROCESS'] = 'true'
    answer_dictionary = {
      'Slightly': 'Somewhat',
      'an incredible': 'a tremendous',
      'a little': 'a little bit',
      'slightly': 'somewhat',
      'a little well': 'slightly well',
      'quite': 'very',
      'a tremendous': 'a very great',
      'somewhat clearly': 'somewhat',
      'almost never': 'once in a while',
      'always': 'all the time',
      'not at all strong': 'not strong at all',
      'each': 'every'
    }
    respondent_map = {}

    unknown_schools = {}
    missing_questions = {}
    bad_answers = {}
    year = '2017'

    timeToRun = 10 * 60
    startIndex = 0
    stopIndex = 100000
    startTime = Time.new

    ['student_responses', 'teacher_responses'].each do |file|
      recipients = file.split('_')[0]
      target_group = Question.target_groups["for_#{recipients}s"]
      csv_string = File.read(File.expand_path("../../../data/#{file}_#{year}.csv", __FILE__))
      csv = CSV.parse(csv_string, :headers => true)
      puts("LOADING CSV: #{csv.length} ROWS")

      t = Time.new
      csv.each_with_index do |row, index|
        next if index < startIndex

        if Time.new - startTime >= timeToRun || index > stopIndex
          puts("ENDING #{timeToRun} SECONDS: #{Time.new - startTime} = #{startIndex} -> #{index} = #{index - startIndex} or #{(Time.new - t) / (index - startIndex)} per second")
          break
        end

        if index % 10 == 0
          puts("DATAMSG: PROCESSING ROW: #{index} OUT OF #{csv.length} ROWS: #{Time.new - t} - Total: #{Time.new - startTime} - #{timeToRun - (Time.new - startTime)} TO GO / #{stopIndex - startIndex} ROWS TO GO")
          t = Time.new
        end

        district_name = row['What district is your school in?']
        district_name = row['To begin, please select your district.'] if district_name.nil?
        district = District.find_or_create_by(name: district_name, state_id: 1)

        school_name = row["Please select your school in #{district_name}."]

        if school_name.blank?
          # puts "BLANK SCHOOL NAME: #{district.name} - #{index}"
          next
        end

        school = district.schools.find_or_create_by(name: school_name)

        if school.nil?
          next if unknown_schools[school_name]
          puts "DATAERROR: Unable to find school: #{school_name} - #{index}"
          unknown_schools[school_name] = true
          next
        end

        respondent_id = row['Response ID']
        recipient_id = respondent_map[respondent_id]
        if recipient_id.present?
          recipient = school.recipients.where(id: recipient_id).first
        else
          begin
            recipient = school.recipients.create(
              name: "Survey Respondent Id: #{respondent_id}"
            )
          rescue
            puts "DATAERROR: INDEX: #{index} ERROR AT #{index} - #{district.name} - #{school_name} #{school}: #{respondent_id}"
          end
          respondent_map[respondent_id] = recipient.id
        end

        recipient_list = school.recipient_lists.find_by_name("#{recipients.titleize} List")
        if recipient_list.nil?
          recipient_list = school.recipient_lists.create(name: "#{recipients.titleize} List")
        end
        recipient_list.recipient_id_array << recipient.id
        recipient_list.save!

        row.each do |key, value|
          t1 = Time.new
          next if value.nil? or key.nil? or value.to_s == "-99"
          key = key.gsub(/[[:space:]]/, ' ').strip.gsub(/\s+/, ' ')
          value = value.gsub(/[[:space:]]/, ' ').strip.downcase

          begin
            question = Question.find_by_text(key)
          rescue Exception => e
            puts "DATAERROR: INDEX: #{index} Failed finding question: #{key} -> #{e}"
          end

          if question.nil?
            next if missing_questions[key]
            puts "DATAERROR: Unable to find question: #{key}"
            missing_questions[key] = true
            next
          else
            question.update_attributes(target_group: target_group) if question.unknown?
          end

          if (value.to_i.blank?)
            answer_index = question.option_index(value)
            answer_dictionary.each do |k, v|
              break if answer_index.present?
              answer_index = question.option_index(value.gsub(k.to_s, v.to_s))
              answer_index = question.option_index(value.gsub(v.to_s, k.to_s)) if answer_index.nil?
            end

            if answer_index.nil?
              next if bad_answers[key]
              puts "DATAERROR: Unable to find answer: #{key} = #{value.downcase.strip} - #{question.options.inspect}"
              bad_answers[key] = true
              next
            end
          else
            answer_index = value.to_i
          end

          responded_at = Date.strptime(row['End Date'], '%m/%d/%Y %H:%M')
          begin
            recipient.attempts.create(question: question, answer_index: answer_index, responded_at: responded_at)
          rescue Exception => e
            puts "DATAERROR: INDEX: #{index}  Attempt failed for #{recipient.inspect} -> QUESTION: #{question.inspect}, ANSWER_INDEX: #{answer_index}, RESPONDED_AT: #{responded_at}, ERROR: #{e}"
            next
          end
        end
      end
    end
    ENV.delete('BULK_PROCESS')
    School.all.each do |school|
      Category.all.each do |category|
        school_category = SchoolCategory.for(school, category).first
        if school_category.nil?
          school_category = SchoolCategory.create(school: school, category: category)
        end
        school_category.sync_aggregated_responses
      end
    end

    Recipient.all.each { |r| r.update_counts }
  end
end
