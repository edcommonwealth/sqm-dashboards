namespace :survey do

  desc 'Text all Recipients ready for an Attempt'
  task :attempt_qustions => :environment do
    Schedule.active.each do |schedule|
      schedule.recipient_schedules.ready.each do |recipient_schedule|
        recipient_schedule.attempt_question
      end
    end
  end
end
