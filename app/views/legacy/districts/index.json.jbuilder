json.array!(@districts) do |district|
  json.extract! district, :id, :name, :state_id
  json.url district_url(district, format: :json)
end
