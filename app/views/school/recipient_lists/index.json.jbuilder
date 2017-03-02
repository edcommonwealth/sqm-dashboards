json.array!(@school_recipient_lists) do |school_recipient_list|
  json.extract! school_recipient_list, :id, :name, :description, :recipient_ids
  json.url school_recipient_list_url(school_recipient_list, format: :json)
end
