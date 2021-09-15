# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'csv'

Item.destroy_all
Construct.destroy_all

csv_file = File.read(Rails.root.join('data', 'AY2020-21_construct_items.csv'))
CSV.parse(csv_file, headers: true).each do |row|
  scale = row['Scale']
  unless scale.nil?
    construct_id = row['Scale'].split(' ').first
    construct_name = row['Scale'].remove("#{construct_id} ")
    watch_low = row['Watch Low']
    growth_low = row['Growth Low']
    approval_low = row['Approval Low']
    ideal_low = row['Ideal Low']
    if Construct.find_by_construct_id(construct_id).nil?
      Construct.create construct_id: construct_id, name: construct_name, watch_low_benchmark: watch_low, growth_low_benchmark: growth_low, approval_low_benchmark: approval_low, ideal_low_benchmark: ideal_low
    end

    item_prompt = row['Survey Item']
    Item.create construct: Construct.find_by_construct_id(construct_id), prompt: item_prompt
  end


end

# questions = Category.find_by_name('Family Subcategory').child_categories.map(&:questions).flatten
# QuestionList.create(name: 'Family Questions', question_id_array: questions.map(&:id))
#
# user = User.create(email: 'jared@edcontext.org', password: '123456')
#
# district = District.create(name: 'EdContext Test District')
# school = School.create(name: 'EdContext Test School', district: district, description: 'A school used to test the EdContext System')
# recipients = [
#   school.recipients.create(name: 'Jared Cosulich', phone: '650-269-3205'),
#   school.recipients.create(name: 'Lauren Cosulich', phone: '6173522365'),
#   school.recipients.create(name: 'Jack Schneider', phone: '+1 267-968-2293'),
#   school.recipients.create(name: 'Lynisse Patin', phone: '19176566892'),
#   school.recipients.create(name: 'Khemenec Patin', phone: '(347) 534-6437'),
# ]
#
# recipients[0].students.create(name: 'Abigail')
# recipients[0].students.create(name: 'Clara')
#
# recipients[3].students.create(name: 'Zara')
# recipients[3].students.create(name: 'Cole')
# recipients[4].students.create(name: 'Zara')
# recipients[4].students.create(name: 'Cole')
#
# recipient_list = school.recipient_lists.create(name: 'Pilot Parent Test', recipient_id_array: recipients.map(&:id))
#
# user.user_schools.create(school: school)

# somerville = District.create(name: 'Somerville Public Schools')
#
# [
#   ['Dr. Albert F. Argenziano School at Lincoln Park',
# """
# The Dr. Albert F. Argenziano School at Lincoln Park is driven by the mission of supporting and fostering an educational and communal environment that results in the development of students who are literate in all subject areas, experienced in current technologies, and who think critically, behave ethically, lead healthy lives, and assume the responsibilities of citizenship in a multicultural and multiracial society. Opened in September 2007, this state-of-the-art facility features upgraded classrooms, a gymnasium, a multi-purpose cafeteria, a library/media center, and a math/science technology center. The Argenziano School at Lincoln Park also serves as the home of the District’s Structured English Immersion Program (SEIP), offering intensive instruction for English Language Learners, including integrated model classrooms in the early grades.
# """
# ], [
#   'Arthur D. Healey School',
# """
# The Arthur D. Healey School is an innovative, participatory learning community that places a high value on academic competence and the belief that children learn best in a joyful, creative environment in which their natural curiosity, imagination and thinking are encouraged.  The school emphasizes learning through creative experiences of project-based learning, arts integration, service learning integration and off-site learning. Learning experiences are designed to engage children’s interest and best efforts, and to promote the importance of community in the lives of children. The Healey School celebrates diversity through its core values of excellence, joy, openness and creativity.
# """
# ], [
#   'Benjamin G. Brown School',
# """
# Built in 1900 and named for Tufts faculty member, the Benjamin G. Brown School is the oldest elementary school in Somerville, and the smallest of the Somerville Public Schools’ elementary schools. The Brown School offers a small school family atmosphere with a strong emphasis on preparing students to excel academically and personally, providing them with the tools to become productive and positive members of society. Teachers participate in professional development endeavors to develop and create engaging teaching strategies that will meet the individual learning needs of their students. Creative learning experiences and a focus on multi-grade relationships like learning buddies and academic mentors, help keep students engaged in their learning and in their community.
# """
# ], [
#   'East Somerville Community School',
# """
# The East Somerville Community School (ESCS) is a diverse learning community in an ethnically rich neighborhood. ESCS’s instructional focus is a school and community-wide effort to increase students’ ability to write to express their thinking and learning across the content areas as measured by the MCAS and school based common assessments. The building, constructed in 2013, features state-of-the-art technology, a beautiful auditorium, child-friendly recreation facilities, outdoor learning environments including a school garden courtyard, energy-saving features, and much more. ESCS is also home to the District’s UNIDOS program, a two-way English/Spanish language and cultural immersion program that enrolls native speakers of English and Spanish to learn together 50% of the day in Spanish and 50% in English.
# """
# ], [
#   'John F. Kennedy Elementary School',
# """
# Somerville’s John F. Kennedy School is driven by the goal of providing all students with academic, social and emotional experiences necessary for future success. The school places a strong emphasis on inclusion, ensuring that all students with special needs can thrive in the general education setting. The Kennedy School is a MA Department of Elementary and Secondary Education Level 1 school, the highest rating in the state’s 5-level accountability rating system. Service learning and History also play prominently in a Kennedy students’ learning experience. Kennedy middle grades students regularly compete in regional, statewide and national History Day competitions, and students at all grade levels have opportunities to learn the value of making a positive difference in their community by engaging in service learning activities throughout the year.
# """
# ], [
#   'Somerville High School',
# """
# Somerville High School (SHS) is a comprehensive high school that blends a rigorous core academic program with cutting-edge Career and Technical Education program. SHS is a Level 1 school on the state accountability rating, and has been recognized by public and private organizations for its achievements. SHS also celebrates a diverse student body, where more than 50 different languages are represented, and classroom experiences regularly connect students with industry and community partners. Along with a rigorous core curriculum, students also benefit from a full complement of Honors and Advanced Placement courses, a complement of World Language courses, a wide range of Art and Music programs, and a rich after-school life that includes athletic, extracurricular and community activities.
# """
# ], [
#   'West Somerville Neighborhood School',
# """
# Staff, parents/guardians and the community of the West Somerville Neighborhood School (WSNS) collaborate for the development of the whole child. The WSNS maintains high expectations for academic achievement and appropriate behavior with mutual respect. In 2014 and 2015, WSNS earned Level 1 designation by the DESE, the highest accountability rating in the state’s 5-level rating system. WSNS focuses on building student writing skills as a way of synthesizing thinking and nurturing creative expression. The school strives to extend and improve students’ learning through the use of assessments, differentiated instruction, the use of technology and interdisciplinary projects. The ultimate goal is to develop students with skills to become independent and self-sufficient adults who contribute responsibly in a global economy.
# """
# ], [
#   'Winter Hill Community Innovation School',
# """
# The Winter Hill Community Innovation School (WHCIS) is a child-centered, academically rich environment that serves a population of students from culturally diverse backgrounds. As part of the school’s collaborative approach to teaching and learning, teachers regularly have one on one conferences with students to assess progress and mutually set goals. In 2014, the WHCIS advanced to Level 2 status on the state’s 5-level accountability rating system. Winter Hill is the district’s first school to receive “Innovation School” designation from the state. As part of its Innovation status, WHCIS enjoys increased autonomy and has been introducing new educational practices to support its vision of using innovative approaches to better meet the varied needs of a highly diverse range of learners.
# """
# ]].each do |school_info|
#   School.create(name: school_info[0], district: somerville, description: school_info[1])
# end
