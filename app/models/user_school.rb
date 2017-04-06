class UserSchool < ApplicationRecord

  belongs_to :user
  belongs_to :school
  belongs_to :district

end
