namespace :survey do

  desc 'Text all recipients ready for an attempt'
  task :attempt_questions => :environment do
    Schedule.active.each do |schedule|
      schedule.recipient_schedules.ready.each do |recipient_schedule|
        recipient_schedule.attempt_question
      end
    end
  end

end
