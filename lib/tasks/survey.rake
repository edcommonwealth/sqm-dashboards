namespace :survey do

  desc 'Text all Recipients ready for an Attempt'
  task :make_attempts => :environment do
    Schedule.active.all.each do |schedule|
      schedule.recipient_schedules.ready.each do |recipient_schedule|

      end
    end
  end
end
