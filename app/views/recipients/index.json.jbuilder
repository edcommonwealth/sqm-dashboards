json.array!(@recipients) do |recipient|
  json.extract! recipient, :id, :name, :phone, :birth_date, :gender, :race, :ethnicity, :home_language_id, :income, :opted_out, :school_id
  json.url recipient_url(recipient, format: :json)
end
