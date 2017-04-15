namespace :survey do

  desc 'Text all Recipients ready for an Attempt (only on weekdays)'
  task :attempt_questions => :environment do
    if Date.today.on_weekday?
      Schedule.active.each do |schedule|
        schedule.recipient_schedules.ready.each do |recipient_schedule|
          recipient_schedule.attempt_question
        end
      end
    end
  end
end
