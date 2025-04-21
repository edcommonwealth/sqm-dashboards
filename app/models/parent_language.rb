class ParentLanguage < ApplicationRecord
  belongs_to :parent
  belongs_to :language
end
