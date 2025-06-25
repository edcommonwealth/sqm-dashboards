class Parent < ApplicationRecord
  belongs_to :housing, optional: true
  belongs_to :education, optional: true
  belongs_to :benefit, optional: true

  has_many :parent_languages
  has_and_belongs_to_many :languages, join_table: :parent_languages
  has_and_belongs_to_many :races, join_table: :parent_races
  has_and_belongs_to_many :genders, join_table: :parent_genders
  has_and_belongs_to_many :employments, join_table: :parent_employments
end
