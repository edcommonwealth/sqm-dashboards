class Parent < ApplicationRecord
  belongs_to :housing, optional: true
  has_many :parent_languages
  has_and_belongs_to_many :languages, join_table: :parent_languages
end
