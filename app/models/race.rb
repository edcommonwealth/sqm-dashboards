class Race < ApplicationRecord
  include FriendlyId
  friendly_id :designation, use: [:slugged]
end
