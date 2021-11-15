json.array!(@question_lists) do |question_list|
  json.extract! question_list, :id, :name, :description, :question_ids
  json.url question_list_url(question_list, format: :json)
end
