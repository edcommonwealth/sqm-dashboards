class Survey < ApplicationRecord
  belongs_to :academic_year
  belongs_to :school

  enum form: {
    normal: 0,
    short: 1
  }, _default: :normal
end
