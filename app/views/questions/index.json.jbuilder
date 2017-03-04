json.array!(@questions) do |question|
  json.extract! question, :id, :text, :option1, :option2, :option3, :option4, :option5, :category_id
  json.url question_url(question, format: :json)
end
