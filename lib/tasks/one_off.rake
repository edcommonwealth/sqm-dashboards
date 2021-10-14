namespace :one_off do
  task clean_up_somerville: :environment do
    combined_school = School.find_by_name 'Next Wave/Full Circle'
    combined_school.update qualtrics_code: 5
    full_circle = School.find_by_name 'Full Circle High School'
    next_wave = School.find_by_name 'Next Wave Junior High School'
    SurveyItemResponse.where(school: [full_circle, next_wave]).update_all school_id: combined_school.id
    full_circle.destroy!
    next_wave.destroy!
  end
end
