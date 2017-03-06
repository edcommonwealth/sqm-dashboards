json.array!(@school_schedules) do |school_schedule|
  json.extract! school_schedule, :id, :name, :description, :school_id, :frequency_hours, :start_date, :end_date, :active, :random, :recipient_list_id, :question_list_id
  json.url school_schedule_url(school_schedule, format: :json)
end
