# PSQL: /Applications/Postgres.app/Contents/Versions/9.6/bin/psql -h localhost

# aws s3 presign s3://irrationaldesign/beta-data-080719a.dump
# sudo heroku pg:backups:restore 'https://irrationaldesign.s3.amazonaws.com/beta-data-080719a.dump?AWSAccessKeyId=AKIAIDGE3EMQEWUQZUJA&Signature=KrabUOeggEd5wrjLQ4bvgd9eZGU%3D&Expires=1565267251' DATABASE_URL -a mciea-beta

# LOAD DATA
# RAILS_ENV=development rails db:environment:set db:drop db:create db:migrate; /Applications/Postgres.app/Contents/Versions/9.6/bin/pg_restore --verbose --clean --no-acl --no-owner -h localhost -d mciea_development beta-data-08092019.dump; rake db:migrate;
# rails c -> SchoolCategory.update_all(year: '2017')
# rake data:load_questions_csv; rake data:load_responses

# sudo heroku pg:reset DATABASE -a mciea-beta
# sudo heroku pg:backups:restore 'https://s3.amazonaws.com/irrationaldesign/beta-data-080818.dump' DATABASE_URL -a mciea-beta
# sudo heroku run rake db:migrate -a mciea-beta
# sudo heroku run console -a mciea-beta -> SchoolCategory.update_all(year: '2017') --
#        RENAME SCHOOLS = s = SCHOOLS; s.each { |correct, incorrect| District.find_by_name("Boston").schools.find_by_name(incorrect[0]).update(name: correct) }
#        s.map { |correct, incorrect| District.find_by_name("Boston").schools.find_by_name(incorrect.to_s).merge_into(correct) }
# sudo heroku run rake data:load_questions_csv -a mciea-beta
# sudo heroku run rake data:load_questions_csv data:sync_questions -a mciea-beta
# sudo heroku run:detached rake data:load_responses -a mciea-beta --size performance-l
# sudo heroku run rake data:move_likert_to_submeasures -a mciea-beta
# sudo heroku run:detached rake data:sync -a mciea-beta --size performance-l

# sudo heroku run:detached rake data:create_school_questions -a mciea-dashboard --size performance-l

# Add:
#
# Category: unique_external_id (string)
# School Category: year (string)
#
# Update:
# Add year to existing school categories

require 'csv'

namespace :data do
  # @year = 2019

  desc 'load survey responses'
  task load_survey_responses: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      SurveyResponsesDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{SurveyItemResponse.count} survey responses"

    puts 'Resetting response rates'
    ResponseRateLoader.reset
    Rails.cache.clear
    puts "=====================> Completed loading #{ResponseRate.count} survey responses"
  end

  desc 'reset response rate values'
  task reset_response_rates: :environment do
    puts 'Resetting response rates'
    ResponseRateLoader.reset
    Rails.cache.clear
    puts "=====================> Completed loading #{ResponseRate.count} survey responses"
  end

  desc 'load admin_data'
  task load_admin_data: :environment do
    Dir.glob(Rails.root.join('data', 'admin_data', '*.csv')).each do |filepath|
      puts "=====================> Loading data from csv at path: #{filepath}"
      AdminDataLoader.load_data filepath:
    end
    puts "=====================> Completed loading #{AdminDataValue.count} survey responses"
  end
  desc 'load students'
  task load_students: :environment do
    Dir.glob(Rails.root.join('data', 'survey_responses', '*.csv')).each do |file|
      puts "=====================> Loading student data from csv at path: #{file}"
      StudentLoader.load_data filepath: file
    end
    puts "=====================> Completed loading #{Student.count} survey responses"
  end

  desc 'reset all cache counters'
  task reset_cache_counters: :environment do
    puts '=====================> Resetting Category counters'
    Category.all.each do |category|
      Category.reset_counters(category.id, :subcategories)
    end
    puts '=====================> Resetting Subcategory counters'
    Subcategory.all.each do |subcategory|
      Subcategory.reset_counters(subcategory.id, :measures)
    end
    puts '=====================> Resetting Measure counters'
    Measure.all.each do |measure|
      Measure.reset_counters(measure.id, :scales)
    end
    puts '=====================> Resetting Scale counters'
    Scale.all.each do |scale|
      Scale.reset_counters(scale.id, :survey_items)
    end
    puts '=====================> Resetting SurveyItem counters'
    SurveyItem.all.each do |survey_item|
      SurveyItem.reset_counters(survey_item.id, :survey_item_responses)
    end
  end

  # desc 'Load in all data'
  # task load: :environment do
  #   # return if School.count > 0
  #   Rake::Task['data:load_categories'].invoke
  #   Rake::Task['data:load_questions'].invoke
  #   Rake::Task['db:seed'].invoke
  #   Rake::Task['data:load_responses'].invoke
  #   Rake::Task['data:load_nonlikert_values'].invoke
  # end

  # desc 'Check question / category data against existing data'
  # task check_questions: :environment do
  #   csv_string = File.read(File.expand_path("../../../data/MeasureKey#{@year}.csv", __FILE__))
  #   csv = CSV.parse(csv_string, headers: true)

  #   t = Time.new
  #   csv.each_with_index do |question, _index|
  #     existing_question = Question.created_in(@year).find_by_external_id(question['qid'])
  #     if existing_question.blank?
  #       puts "NOT FOUND: #{question['qid']} -> #{question['Question Text']}"
  #     else
  #       puts "MULTIPLE FOUND: #{question['qid']}" if Question.where(external_id: question['qid']).count > 1

  #       question_text = question['Question Text'].gsub(/[[:space:]]/, ' ').strip
  #       if existing_question.text != question_text
  #         puts "CHANGED TEXT: #{question['qid']} -> #{question_text} != #{existing_question.text}"
  #       end

  #       5.times do |j|
  #         i = j + 1
  #         if existing_question.send("option#{i}") != question["R#{i}"]
  #           if question["R#{i}"].blank?
  #             puts "MISSING #{i}: #{question.inspect}"
  #           else
  #             puts "CHANGED OPTION #{i}: #{question['qid']} -> #{question["R#{i}"]} != #{existing_question.send("option#{i}")}"
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  # desc 'Sync questions / category data against existing data'
  # task sync_questions: :environment do
  #   csv_string = File.read(File.expand_path("../../../data/MeasureKey#{@year}.csv", __FILE__))
  #   csv = CSV.parse(csv_string, headers: true)

  #   t = Time.new
  #   csv.each_with_index do |question, _index|
  #     existing_question = Question.created_in(@year).find_by_external_id(question['qid'])
  #     if existing_question.blank?
  #       categories = Category.where(name: question['Category Name'].titleize)
  #       if categories.blank?
  #         puts "Category not found for new question: #{question['Category Name'].titleize} - #{question['qid']}"
  #       elsif categories.count > 1
  #         puts "Multiple categories found for new question: #{question['Category Name']} - #{question['qid']}"
  #       else
  #         puts "CREATING NEW QUESTION: #{categories.first.name} - #{question['qid']} - #{question['Question Text']}"
  #         categories.first.questions.create(
  #           external_id: question['qid'],
  #           text: question['Question Text'],
  #           option1: question['R1'],
  #           option2: question['R2'],
  #           option3: question['R3'],
  #           option4: question['R4'],
  #           option5: question['R5'],
  #           target_group: question['qid'].starts_with?('s') ? 'for_students' : 'for_teachers',
  #           reverse: question['Reverse'] == '1'
  #         )
  #       end
  #     else
  #       if Question.created_in(@year).where(external_id: question['qid']).count > 1
  #         puts "MULTIPLE FOUND: #{question['qid']}"
  #       end

  #       question_text = question['Question Text'].gsub(/[[:space:]]/, ' ').strip
  #       if existing_question.text != question_text
  #         existing_question.update(text: question_text)
  #         puts "UPDATING TEXT: #{question['qid']} -> #{question_text} != #{existing_question.text}"
  #       end

  #       5.times do |j|
  #         i = j + 1
  #         if existing_question.send("option#{i}") != question["R#{i}"]
  #           if question["R#{i}"].blank?
  #             puts "MISSING #{i}: #{question.inspect}"
  #           else
  #             existing_question.update("option#{i}": question["R#{i}"])
  #             puts "UPDATING OPTION #{i}: #{question['qid']} -> #{question["R#{i}"]} != #{existing_question.send("option#{i}")}"
  #           end
  #         end
  #       end
  #     end
  #   end
  # end

  # desc 'Load in category data'
  # task load_categories: :environment do
  #   measures = JSON.parse(File.read(File.expand_path('../../data/measures.json', __dir__)))
  #   measures.each_with_index do |measure, index|
  #     category = Category.create_with(
  #       blurb: measure['blurb'],
  #       description: measure['text'],
  #       external_id: measure['id'] || index + 1
  #     ).find_or_create_by(name: measure['title'])

  #     measure['sub'].keys.sort.each do |key|
  #       subinfo = measure['sub'][key]
  #       subcategory = category.child_categories.create_with(
  #         blurb: subinfo['blurb'],
  #         description: subinfo['text'],
  #         external_id: key
  #       ).find_or_create_by(name: subinfo['title'])

  #       subinfo['measures'].keys.sort.each do |subinfo_key|
  #         subsubinfo = subinfo['measures'][subinfo_key]
  #         subsubcategory = subcategory.child_categories.create_with(
  #           blurb: subsubinfo['blurb'],
  #           description: subsubinfo['text'],
  #           external_id: subinfo_key
  #         ).find_or_create_by(name: subsubinfo['title'])

  #         next unless subsubinfo['nonlikert'].present?

  #         subsubinfo['nonlikert'].each do |nonlikert_info|
  #           puts("NONLIKERT FOUND: #{nonlikert_info['title']}")
  #           nonlikert = subsubcategory.child_categories.create_with(
  #             benchmark_description: nonlikert_info['benchmark_explanation'],
  #             benchmark: nonlikert_info['benchmark']
  #           ).find_or_create_by(name: nonlikert_info['title'])
  #         end
  #       end
  #     end
  #   end
  # end

  # desc 'Load in question data from json'
  # task load_questions: :environment do
  #   variations = [
  #     '[Field-MathTeacher][Field-ScienceTeacher][Field-EnglishTeacher][Field-SocialTeacher]',
  #     'teacher'
  #   ]

  #   questions = JSON.parse(File.read(File.expand_path('../../data/questions.json', __dir__)))
  #   questions.each do |question|
  #     category = nil
  #     question['category'].split('-').each do |external_id|
  #       categories = category.present? ? category.child_categories : Category
  #       category = categories.where(external_id:).first
  #       next unless category.nil?

  #       puts 'NOTHING'
  #       puts external_id
  #       puts categories.inspect
  #       category = categories.create(name: question['Category Name'], external_id:)
  #     end
  #     question_text = question['text'].gsub(/[[:space:]]/, ' ').strip
  #     if question_text.index('.* teacher').nil?
  #       category.questions.create(
  #         text: question_text,
  #         option1: question['answers'][0],
  #         option2: question['answers'][1],
  #         option3: question['answers'][2],
  #         option4: question['answers'][3],
  #         option5: question['answers'][4],
  #         for_recipient_students: question['child'].present?,
  #         reverse: question['Reverse'] == '1'
  #       )
  #     else
  #       variations.each do |variation|
  #         category.questions.create(
  #           text: question_text.gsub('.* teacher', variation),
  #           option1: question['answers'][0],
  #           option2: question['answers'][1],
  #           option3: question['answers'][2],
  #           option4: question['answers'][3],
  #           option5: question['answers'][4],
  #           for_recipient_students: question['child'].present?,
  #           reverse: question['Reverse'] == '1'
  #         )
  #       end
  #     end
  #   end
  # end

  # desc 'Load in question data from csv'
  # task load_questions_csv: :environment do
  #   variations = [
  #     '[Field-MathTeacher][Field-ScienceTeacher][Field-EnglishTeacher][Field-SocialTeacher]',
  #     'teacher'
  #   ]

  #   csv_string = File.read(File.expand_path("../../../data/MeasureKey#{@year}.csv", __FILE__))
  #   csv = CSV.parse(csv_string, headers: true)

  #   t = Time.new
  #   csv.each_with_index do |question, _index|
  #     category = nil
  #     question['Category19'].split('-').each do |external_id_raw|
  #       external_id = external_id_raw.gsub(/[[:space:]]/, ' ').strip
  #       categories = category.present? ? category.child_categories : Category
  #       category = categories.where(external_id:).first
  #       next unless category.nil?

  #       puts 'NOTHING'
  #       puts "#{question['Category']} -- #{external_id}"
  #       puts categories.map { |c|
  #              "#{c.name} - |#{c.external_id}| == |#{external_id}|: - #{external_id == c.external_id}"
  #            }.join(' ---- ')
  #       category = categories.create(name: question['Category Name'], external_id:)
  #     end
  #     question_text = question['Question Text'].gsub(/[[:space:]]/, ' ').strip
  #     if question_text.index('.* teacher').nil?
  #       category.questions.create(
  #         text: question_text,
  #         option1: question['R1'],
  #         option2: question['R2'],
  #         option3: question['R3'],
  #         option4: question['R4'],
  #         option5: question['R5'],
  #         for_recipient_students: question['Level'] == 'Students',
  #         external_id: question['qid'],
  #         reverse: question['Reverse'] == '1'
  #       )
  #     else
  #       variations.each do |variation|
  #         category.questions.create(
  #           text: question_text.gsub('.* teacher', variation),
  #           option1: question['R1'],
  #           option2: question['R2'],
  #           option3: question['R3'],
  #           option4: question['R4'],
  #           option5: question['R5'],
  #           for_recipient_students: question['Level'] == 'Students',
  #           external_id: question['qid'],
  #           reverse: question['Reverse'] == '1'
  #         )
  #       end
  #     end
  #   end
  # end

  # desc 'Load in student and teacher responses'
  # task load_responses: :environment do
  #   ENV['BULK_PROCESS'] = 'true'
  #   answer_dictionary = {
  #     'Slightly': 'Somewhat',
  #     'an incredible': 'a tremendous',
  #     'a little': 'a little bit',
  #     'slightly': 'somewhat',
  #     'a little well': 'slightly well',
  #     'quite': 'very',
  #     'a tremendous': 'a very great',
  #     'somewhat clearly': 'somewhat',
  #     'almost never': 'once in a while',
  #     'always': 'all the time',
  #     'not at all strong': 'not strong at all',
  #     'each': 'every'
  #   }
  #   respondent_map = {}

  #   unknown_schools = {}
  #   missing_questions = {}
  #   bad_answers = {}

  #   timeToRun = 120_000 * 60
  #   startIndex = 0
  #   stopIndex = 1_000_000
  #   startTime = Time.new

  #   # ['teacher_responses'].each do |file|
  #   %w[student_responses teacher_responses].each do |file|
  #     recipients = file.split('_')[0]
  #     target_group = Question.target_groups["for_#{recipients}s"]
  #     csv_string = File.read(File.expand_path("../../../data/#{file}_#{@year}.csv", __FILE__))
  #     csv = CSV.parse(csv_string, headers: true)
  #     puts("LOADING CSV: #{csv.length} ROWS")

  #     t = Time.new
  #     csv.each_with_index do |row, index|
  #       next if index < startIndex

  #       if Time.new - startTime >= timeToRun || index > stopIndex
  #         puts("ENDING #{timeToRun} SECONDS: #{Time.new - startTime} = #{startIndex} -> #{index} = #{index - startIndex} or #{(Time.new - t) / (index - startIndex)} per second")
  #         break
  #       end

  #       if index % 10 == 0
  #         puts("DATAMSG: PROCESSING ROW: #{index} OUT OF #{csv.length} ROWS: #{Time.new - t} - Total: #{Time.new - startTime} - #{timeToRun - (Time.new - startTime)} TO GO / #{stopIndex - startIndex} ROWS TO GO")
  #         t = Time.new
  #       end

  #       district_name = row['Q111'].strip
  #       if district_name.blank? || district_name == 'NA'
  #         puts "DISTRICT NOT FOUND: #{district_name}"
  #         next
  #       end
  #       # district_name = row['To begin, please select your district.'] if district_name.nil?
  #       district = District.find_or_create_by(name: district_name, state_id: 1)

  #       school_name = row['SchoolName'].strip

  #       if school_name.blank? || school_name == 'NA'
  #         puts "BLANK SCHOOL NAME: #{district.name} - #{index}"
  #         next
  #       end

  #       school = district.schools.find_or_create_by(name: school_name)

  #       if school.nil?
  #         next if unknown_schools[school_name]

  #         puts "DATAERROR: Unable to find school: #{school_name} - #{index}"
  #         unknown_schools[school_name] = true
  #         next
  #       end

  #       respondent_id = "#{recipients}-#{index}-#{row['ResponseId'].strip}"
  #       recipient_id = respondent_map["#{school.id}-#{@year}-#{respondent_id}"]
  #       recipient = school.recipients.where(id: recipient_id).first if recipient_id.present?

  #       if recipient.nil?
  #         begin
  #           recipient = school.recipients.create(
  #             name: "Survey Respondent Id: #{respondent_id}"
  #           )
  #         rescue StandardError
  #           puts "DATAERROR: INDEX: #{index} ERROR AT #{index} - #{district.name} - #{school_name} #{school}: #{respondent_id}"
  #         end
  #         respondent_map["#{school.id}-#{respondent_id}"] = recipient.id
  #       end

  #       recipient_list = school.recipient_lists.find_by_name("#{recipients.titleize} List")
  #       recipient_list = school.recipient_lists.create(name: "#{recipients.titleize} List") if recipient_list.nil?
  #       recipient_list.recipient_id_array << recipient.id
  #       recipient_list.save!

  #       row.each do |key, value|
  #         t1 = Time.new
  #         next if value.nil? or key.nil? or value.to_s == '-99'

  #         key = key.gsub(/[[:space:]]/, ' ').gsub(/\./, '-').strip.gsub(/\s+/, ' ')
  #         key = key.gsub(/-4-5/, '').gsub(/-6-12/, '')
  #         value = value.gsub(/[[:space:]]/, ' ').strip.downcase

  #         begin
  #           question = Question.created_in(@year).find_by_external_id(key)
  #         rescue Exception => e
  #           puts "DATAERROR: INDEX: #{index} Failed finding question: #{key} -> #{e}"
  #         end

  #         if question.nil?
  #           next if missing_questions[key]

  #           puts "DATAERROR: Unable to find question: #{key}"
  #           missing_questions[key] = true
  #           next
  #         elsif question.unknown?
  #           question.update_attributes(target_group:)
  #         end

  #         if value.to_i.blank?
  #           answer_index = question.option_index(value)
  #           answer_dictionary.each do |k, v|
  #             break if answer_index.present?

  #             answer_index = question.option_index(value.gsub(k.to_s, v.to_s))
  #             answer_index = question.option_index(value.gsub(v.to_s, k.to_s)) if answer_index.nil?
  #           end

  #           if answer_index.nil?
  #             next if bad_answers[key]

  #             puts "DATAERROR: Unable to find answer: #{key} = #{value.downcase.strip} - #{question.options.inspect}"
  #             bad_answers[key] = true
  #             next
  #           end
  #         else
  #           answer_index = value.to_i
  #         end

  #         next if answer_index == 0

  #         # answer_index = 6 - answer_index if question.reverse?

  #         responded_at = begin
  #           Date.strptime(row['recordedDate'], '%Y-%m-%d %H:%M:%S')
  #         rescue StandardError
  #           Date.today
  #         end
  #         begin
  #           recipient.attempts.create(question:, answer_index:, responded_at:)
  #         rescue Exception => e
  #           puts "DATAERROR: INDEX: #{index}  Attempt failed for #{recipient.inspect} -> QUESTION: #{question.inspect}, ANSWER_INDEX: #{answer_index}, RESPONDED_AT: #{responded_at}, ERROR: #{e}"
  #           next
  #         end
  #       end
  #     end
  #   end
  #   ENV.delete('BULK_PROCESS')

  #   sync_school_category_aggregates

  #   # Recipient.created_in(@year).each { |r| r.update_counts }
  # end

  # desc 'Load in nonlikert values for each school'
  # task load_nonlikert_values: :environment do
  #   csv_string = File.read(File.expand_path('../../data/MCIEA_18-19AdminData_Final.csv', __dir__))
  #   # csv_string = File.read(File.expand_path("../../../data/MCIEA_16-17_SGP.csv", __FILE__))
  #   csv = CSV.parse(csv_string, headers: true)
  #   puts("LOADING NONLIKERT CSV: #{csv.length} ROWS")

  #   errors = []
  #   csv.each_with_index do |row, _index|
  #     next if row['Likert_Value'].blank?

  #     base = Category
  #     category_ids = row['Category'].split('-')
  #     category_ids.each do |category_id|
  #       category_id = category_id.downcase if category_id.downcase =~ /i/
  #       base = base.find_by_external_id(category_id)
  #       if base.nil?
  #         row['reason'] = "Unable to find category_id #{category_id} for category #{row['Category']}"
  #         errors << row
  #         next
  #       end
  #       base = base.child_categories
  #     end

  #     nonlikert_category = base.where(name: row['NonLikert Title']).first

  #     if nonlikert_category.nil?
  #       row['reason'] = "Unable to find nonlikert category: #{row['NonLikert Title']} in "
  #       errors << row
  #       next
  #     elsif (benchmark = row['Benchmark']).present?
  #       nonlikert_category.update(benchmark:)
  #     end

  #     district = District.where(name: row['District'], state_id: 1).first
  #     if district.blank?
  #       row['reason'] = "DISTRICT NOT FOUND: #{row['District']}"
  #       errors << row
  #       next
  #     end

  #     school = district.schools.where(name: row['School']).first
  #     if school.blank?
  #       row['reason'] = "SCHOOL NOT FOUND: #{row['School']} (#{district.name})"
  #       errors << row
  #       next
  #     end

  #     school_category = school.school_categories.find_or_create_by(category: nonlikert_category, year: @year.to_s)
  #     if school_category.blank?
  #       row['reason'] = "SCHOOL CATEGORY NOT FOUND: #{school.name} (#{district.name}) #{nonlikert_category.name}"
  #       errors << row
  #       next
  #     end

  #     zscore = ([-2, [row['Likert_Value'].to_f - 3, 2].min].max * 10).to_i.to_f / 10.0
  #     school_category.update(
  #       nonlikert: row['NL_Value'],
  #       zscore: zscore.to_f,
  #       year: @year.to_s,
  #       valid_child_count: 1
  #     )

  #     school_category.reload.sync_aggregated_responses
  #   end

  #   errors.each do |error|
  #     puts "#{error['reason']}: #{error['NonLikert Title']} -> #{error['Likert_Value']}"
  #   end

  #   puts "COUNT: #{SchoolCategory.where(attempt_count: 0,
  #                                       answer_index_total: 0).where('nonlikert is not null and zscore is null').count}"
  # end

  # desc 'Load in custom zones for each category'
  # task load_custom_zones: :environment do
  #   ENV['BULK_PROCESS'] = 'true'

  #   csv_string = File.read(File.expand_path('../../data/Benchmarks2016-2017.csv', __dir__))
  #   csv = CSV.parse(csv_string, headers: true)

  #   csv.each_with_index do |row, _index|
  #     next if row['Warning High'].blank?

  #     category = Category.find_by_name(row['Subcategory'])

  #     if category.nil?
  #       puts "Unable to find category #{row['Subcategory']}"
  #       next
  #     end

  #     custom_zones = [
  #       row['Warning High'],
  #       row['Watch High'],
  #       row['Growth High'],
  #       row['Approval High'],
  #       5
  #     ]

  #     puts "#{category.name} -> #{custom_zones.join(',')}"

  #     category.update(zones: custom_zones.join(','))
  #   end

  #   ENV.delete('BULK_PROCESS')

  #   Category.all.each { |category| category.sync_child_zones }
  # end

  # desc 'Move all likert survey results to a new submeasure of current measure'
  # task move_likert_to_submeasures: :environment do
  #   Question.all.each do |q|
  #     category = q.category
  #     next unless category.name.index('Scale').nil?

  #     new_category_name = "#{category.name} Scale"
  #     new_category = category.child_categories.where(name: new_category_name).first
  #     if new_category.nil?
  #       new_category = category.child_categories.create(
  #         name: new_category_name,
  #         blurb: "This measure contains all survey responses for #{category.name}.",
  #         description: "The following survey questions concern perceptions of #{category.name}.",
  #         zones: category.zones
  #       )
  #     end
  #     q.update(category: new_category)
  #   end

  #   # sync_school_category_aggregates
  # end

  # desc 'Sync all school category aggregates'
  # task sync: :environment do
  #   sync_school_category_aggregates

  #   # Recipient.created_in(@year).each { |r| r.update_counts }
  # end

  # desc 'Create School Questions'
  # task create_school_questions: :environment do
  #   Category.joins(:questions).uniq.all.each do |category|
  #     category.school_categories.in(@year).joins(school: :district).where("districts.name = 'Boston'").find_in_batches(batch_size: 100) do |group|
  #       group.each do |school_category|
  #         school_questions = []
  #         new_school_questions = []
  #         category.questions.created_in(@year).each do |question|
  #           school = school_category.school
  #           next if school.district.name != 'Boston'

  #           school_question = school_category.school_questions.for(school, question).first
  #           if school_question.present?
  #             school_questions << school_question
  #           else
  #             attempt_data = Attempt
  #                            .joins(:question)
  #                            .created_in(school_category.year)
  #                            .for_question(question)
  #                            .for_school(school)
  #                            .select('count(attempts.answer_index) as response_count')
  #                            .select('sum(case when questions.reverse then 6 - attempts.answer_index else attempts.answer_index end) as answer_index_total')[0]

  #             available_responders = school.available_responders_for(question)

  #             school_question = school_category.school_questions.new(
  #               school:,
  #               question:,
  #               school_category:,
  #               year: school_category.year,
  #               attempt_count: available_responders,
  #               response_count: attempt_data.response_count,
  #               response_rate: attempt_data.response_count.to_f / available_responders.to_f,
  #               response_total: attempt_data.answer_index_total
  #             )
  #             new_school_questions << school_question
  #             school_questions << school_question
  #           end
  #         end

  #         SchoolQuestion.import new_school_questions
  #       end
  #     end
  #   end
  # end

  # def sync_school_category_aggregates
  #   School.all.each do |school|
  #     Category.all.each do |category|
  #       school_category = SchoolCategory.for(school, category).in(@year).first
  #       school_category = school.school_categories.create(category:, year: @year) if school_category.nil?
  #       school_category.sync_aggregated_responses
  #     end
  #   end
  # end
# end

# <SchoolCategory id: 1, school_id: 1, category_id: 1, attempt_count: 277, response_count: 277, answer_index_total: 1073, created_at: "2017-10-17 00:21:52", updated_at: "2018-03-03 17:24:53", nonlikert: nil, zscore: 0.674396962759463, year: "2017">

# require 'csv'
# student_counts_string = File.read(File.expand_path("data/bps_student_counts.csv"))
# student_counts = CSV.parse(student_counts_string, :headers => true)
# missing_schools = []
# student_counts.each_with_index do |count, index|
#   school = School.find_by_name(count["SCHOOL NAME"])
#
#   if school.nil?
#     puts("Unable to find school: #{count["SCHOOL NAME"]}")
#     missing_schools << count["SCHOOL NAME"]
#     next
#   end
#
#   school.update(student_count: count["Student Enrollment (Grades 4-11)"])
# end
# puts ""
# puts "MISSING SCHOOLS: #{missing_schools.length}"
# missing_schools.each { |s| puts(s) }
#
#

# require 'csv'
# teacher_counts_string = File.read(File.expand_path("data/bps_counts_2019.csv"))
# teacher_counts = CSV.parse(teacher_counts_string, :headers => true)
# missing_schools = []
# teacher_counts.each_with_index do |count, index|
#   school = School.find_by_name(count["SCHOOL NAME"])
#
#   if school.nil?
#     puts("Unable to find school: #{count["SCHOOL NAME"]}")
#     missing_schools << count["SCHOOL NAME"]
#     next
#   end
#
#   school.update(
#     student_count: count["Students in grades 4-11"],
#     teacher_count: count["Teacher Denominator"]
#   )
# end
# puts ""
# puts "MISSING SCHOOLS: #{missing_schools.length}"
# missing_schools.each { |s| puts(s) }
#
#

# min_response_rate = 0.3
# level = 1
# # categories = Category.joins(:questions).uniq.all
# # categories = [Category.find_by_slug("student-emotional-safety-scale")]
# questions = Question.created_in(2019).where(reverse: true, target_group: "for_students")
# categories = questions.map(&:category).uniq
#
# categories.each do |category|
#   category.school_categories.in(2019).joins(school: :district).where("districts.name = 'Boston'").each do |school_category|
#   # category.school_categories.joins(school: :district).where("districts.name = 'Boston' and schools.slug = 'boston-community-leadership-academy'").each do |school_category|
#     school_question_data = school_category.
#       school_questions.
#       where("response_rate > #{min_response_rate}").
#       select('count(response_count) as valid_child_count').
#       select('sum(response_count) as response_count').
#       select('sum(response_total) as response_total')[0]
#
#     valid_child_count = school_question_data.valid_child_count
#     school_questions = school_category.school_questions.joins(:question)
#     student_questions = school_questions.merge(Question.for_students)
#     teacher_questions = school_questions.merge(Question.for_teachers)
#     if (student_questions.count > 0 && teacher_questions.count > 0)
#         # NEED TO CHECK IF STUDENT OR TEACHER QUESTIONS EXIST
#
#       if (student_questions.where("response_rate > #{min_response_rate}").count == 0 ||
#           teacher_questions.where("response_rate > #{min_response_rate}").count == 0)
#           valid_child_count = 0
#       end
#     end
#
#     puts "VALID CHILD COUNT: #{valid_child_count}"
#     school_category.update(
#       valid_child_count: valid_child_count,
#       response_count: school_question_data.response_count,
#       answer_index_total: school_question_data.response_total,
#       zscore: (school_question_data.response_total.to_f/school_question_data.response_count.to_f) - 3.to_f
#     )
#   end
# end
#
# categories = Category.where("slug like '%-scale'")
#
# loop do
#   parent_categories = []
#   categories.each_with_index do |category, i|
#     parent_category = category.parent_category
#     next if parent_category.nil? || parent_categories.include?(parent_category)
#     parent_categories << parent_category
#
#     school_categories = parent_category.school_categories.joins(school: :district).where("districts.name = 'Boston'")
#     school_categories.each_with_index do |school_category, index|
#       school = school_category.school
#
#       children = SchoolCategory.for_parent_category(school, parent_category).in(school_category.year)
#       valid_children = children.where("valid_child_count > 0")
#       school_category.update(
#         valid_child_count: valid_children.count,
#         response_count: valid_children.sum(&:response_count),
#         answer_index_total: valid_children.sum(&:answer_index_total),
#         zscore: (valid_children.sum(&:answer_index_total).to_f / valid_children.sum(&:response_count).to_f) - 3.to_f
#       )
#     end
#   end
#
#   puts ""
#   puts ""
#   puts "PARENT CATEGORIES: #{parent_categories.uniq.length}"
#   puts ""
#   puts ""
#
#   # level += 1
#   categories = parent_categories.uniq
#   break if categories.blank?
# end

# total = 0
# District.find_by_name('Somerville').schools.each do |school|
#   base_categories = Category.joins(:questions).map(&:parent_category).to_a.flatten.uniq
#   base_categories.each do |category|
#     SchoolCategory.for(school, category).in("2018").valid.each do |school_category|
#       dup_school_categories = SchoolCategory.for(school, category).in("2018")
#       if dup_school_categories.count > 1
#         dup_school_categories.each { |dsc| dsc.destroy unless dsc.id == school_category.id }
#         school_category.sync_aggregated_responses
#         parent = category.parent_category
#         while parent != nil
#           SchoolCategory.for(school, parent).in("2018").valid.each do |parent_school_category|
#             parent_dup_school_categories = SchoolCategory.for(school, parent).in("2018")
#             if parent_dup_school_categories.count > 1
#               parent_dup_school_categories.each { |pdsc| pdsc.destroy unless pdsc.id == parent_school_category.id }
#               parent_school_category.sync_aggregated_responses
#             end
#           end
#           parent = parent.parent_category
#         end
#         # total += 1
#       end
#     end
#   end
# end
#
# puts "TOTAL: #{total}"

# [
#   "next-wave-full-circle"
# ].each do |slug|
#   school = School.find_by_slug(slug)
#   base_categories = Category.all.to_a.flatten.uniq
#   base_categories.each do |category|
#     SchoolCategory.for(school, category).in(2018).each do |school_category|
#       dup_school_categories = SchoolCategory.for(school, category).in(school_category.year)
#       if dup_school_categories.count > 1
#         puts dup_school_categories.first.inspect
#         dup_school_categories.each { |dsc| dsc.destroy unless dsc.id == school_category.id }
#         school_category.sync_aggregated_responses
#         parent = category.parent_category
#         while parent != nil
#           SchoolCategory.for(school, parent).in(school_category.year).valid.each do |parent_school_category|
#             parent_dup_school_categories = SchoolCategory.for(school, parent).in(school_category.year)
#             if parent_dup_school_categories.count > 1
#               parent_dup_school_categories.each { |pdsc| pdsc.destroy unless pdsc.id == parent_school_category.id }
#               parent_school_category.sync_aggregated_responses
#             end
#           end
#           parent = parent.parent_category
#         end
#       end
#     end
#   end
# end
#
# category = Category.find_by_slug("professional-qualifications-scale")
# category.school_categories.joins(:school).each do |school_category|
#   school_question_data = school_category.
#     school_questions.
#     where("response_rate > #{min_response_rate}").
#     select('count(response_count) as valid_child_count').
#     select('sum(response_count) as response_count').
#     select('sum(response_total) as response_total')[0]
#
#   valid_child_count = school_question_data.valid_child_count
#   school_questions = school_category.school_questions.joins(:question)
#   student_questions = school_questions.merge(Question.for_students)
#   teacher_questions = school_questions.merge(Question.for_teachers)
#   if (student_questions.count > 0 && teacher_questions.count > 0)
#     if (student_questions.where("response_rate > #{min_response_rate}").count == 0 ||
#         teacher_questions.where("response_rate > #{min_response_rate}").count == 0)
#         valid_child_count = 0
#     end
#   end
#
#   puts "VALID CHILD COUNT: #{valid_child_count}"
#   school_category.update(
#     valid_child_count: valid_child_count,
#     response_count: school_question_data.response_count,
#     answer_index_total: school_question_data.response_total,
#     zscore: (school_question_data.response_total.to_f/school_question_data.response_count.to_f) - 3.to_f
#   )
# end
#
#
# category = Category.find_by_slug("professional-qualifications-scale")
# school = School.find_by_slug("young-achievers-science-and-math-k-8-school")
# school_category = SchoolCategory.for(school,category).in("2018").first
# school_category.school_questions.each do |school_question|
#   attempt_data = Attempt.
#     joins(:question).
#     created_in(school_category.year).
#     for_question(school_question.question).
#     for_school(school).
#     select('count(attempts.answer_index) as response_count').
#     select('sum(case when questions.reverse then 6 - attempts.answer_index else attempts.answer_index end) as answer_index_total')[0]
#
#   available_responders = school.available_responders_for(school_question.question)
#
#   school_question.update(
#     attempt_count: available_responders,
#     response_count: attempt_data.response_count,
#     response_rate: attempt_data.response_count.to_f / available_responders.to_f,
#     response_total: attempt_data.answer_index_total
#   )
# end
#
# min_response_rate = 0.3
# school_question_data = school_category.
#   school_questions.
#   where("response_rate > #{min_response_rate}").
#   select('count(response_count) as valid_child_count').
#   select('sum(response_count) as response_count').
#   select('sum(response_total) as response_total')[0]
#
# valid_child_count = school_question_data.valid_child_count
# school_questions = school_category.school_questions.joins(:question)
# student_questions = school_questions.merge(Question.for_students)
# teacher_questions = school_questions.merge(Question.for_teachers)
# if (student_questions.count > 0 && teacher_questions.count > 0)
#   if (student_questions.where("response_rate > #{min_response_rate}").count == 0 ||
#       teacher_questions.where("response_rate > #{min_response_rate}").count == 0)
#       valid_child_count = 0
#   end
# end
#
# puts "VALID CHILD COUNT: #{valid_child_count}"
# school_category.update(
#   valid_child_count: valid_child_count,
#   response_count: school_question_data.response_count,
#   answer_index_total: school_question_data.response_total,
#   zscore: (school_question_data.response_total.to_f/school_question_data.response_count.to_f) - 3.to_f
# )
#
# parent = category.parent_category
# while parent != nil
#   SchoolCategory.for(school, parent).in("2018").valid.each do |parent_school_category|
#     parent_school_category.sync_aggregated_responses
#   end
#   parent = parent.parent_category
# end
#
#
# category = Category.find_by_slug("health")
# District.find_by_name("Boston").schools.each do |school|
#   school_category = SchoolCategory.for(school, category).in("2018")
#   valid_children = SchoolCategory.for_parent_category(school, category).in("2018").where("valid_child_count > 0")
#   if valid_children.count == 1 && valid_children.first.category.slug == "physical-health"
#     school_category.update(valid_child_count: 0)
#     parent = category.parent_category
#     while parent != nil do
#       parent_school_category = SchoolCategory.for(school, parent).in("2018")
#       valid_children = SchoolCategory.for_parent_category(school, parent).in("2018").where("valid_child_count > 0")
#       parent_school_category.update(valid_child_count: valid_children.count)
#       parent = parent.parent_category
#     end
#   end
# end

# Question.created_in(2019).each do |question|
#   previous_year_question = Question.created_in(2018).find_by_external_id(question.external_id)
#   if previous_year_question.nil?
#     puts("No previous year question: #{question.external_id}")
#     previous_year_question = Question.created_in(2018).find_by_external_id("s-peff-q6")
#   end
#   question.update(category: previous_year_question.category)
# end

# categories = []
# Question.created_in(2019).where(reverse: true).each do |question|
#   question.attempts.each do |attempt|
#     attempt.update(answer_index: 6 - attempt.answer_index)
#   end
#   categories << question.category
# end
# categories.uniq.each do |category|
#   category.school_categories.in(2019).each do |school_category|
#     school_category.sync_aggregated_responses
#   end
# end

# questions = Question.created_in(2019).where(reverse: true, target_group: "for_students")
# categories = questions.map(&:category).uniq
# schools = District.find_by_name("Boston").schools
# schools.each_with_index do |school, si|
#   ENV['BULK_PROCESS'] = 'true'
#
#   questions.each_with_index do |question, qi|
#     attempts = Attempt.for_school(school).for_question(question)
#     puts "XXXXX School #{si}/#{schools.length}, Question #{qi}/#{questions.length}, Attempts: #{attempts.length}"
#     attempts.each do |attempt|
#       attempt.update(answer_index: attempt.answer_index_with_reverse)
#     end
#
#     SchoolQuestion.for(school, question).in(2019).each { |sq| sq.sync_attempts() }
#   end
#
#   ENV.delete('BULK_PROCESS')
end
