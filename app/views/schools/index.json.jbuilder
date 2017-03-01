json.array!(@schools) do |school|
  json.extract! school, :id, :name, :district_id
  json.url school_url(school, format: :json)
end
