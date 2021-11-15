module Legacy
  class Student < ApplicationRecord
    belongs_to :recipient
  end
end
