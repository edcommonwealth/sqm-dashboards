class AddTimeToSchedule < ActiveRecord::Migration[5.0]
  def change
    add_column :schedules, :time, :integer, default: 960
  end
end
