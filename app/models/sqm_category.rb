class SqmCategory < ActiveRecord::Base
  has_many :subcategories
end
