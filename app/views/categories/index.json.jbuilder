json.array!(@categories) do |category|
  json.extract! category, :id, :name, :blurb, :description, :external_id, :parent_category_id
  json.url category_url(category, format: :json)
end
