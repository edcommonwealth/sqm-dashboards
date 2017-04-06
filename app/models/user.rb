class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :user_schools

  def schools
    districts = user_schools.map(&:district).compact.uniq
    (user_schools.map(&:school) + districts.map(&:schools)).flatten.compact.uniq
  end

  def admin?(school)
    schools.index(school).present?
  end
end
