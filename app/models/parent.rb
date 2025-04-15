class Parent < ApplicationRecord
  belongs_to :language, optional: true
  belongs_to :housing, optional: true
end
