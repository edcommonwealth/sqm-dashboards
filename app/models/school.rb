class School < ApplicationRecord
  has_many :schedules, dependent: :destroy
  has_many :recipient_lists, dependent: :destroy
  belongs_to :district
  has_many :recipients, dependent: :destroy
  has_many :school_categories, dependent: :destroy
  has_many :user_schools, dependent: :destroy

  validates :name, presence: true

  scope :alphabetic, -> { order(name: :asc) }

  include FriendlyId
  friendly_id :name, :use => [:slugged]

  def merge_into(school)
    puts "Merging #{name} (#{id}) in to #{school.name} (#{school.id})"
    schedules.update_all(school: school)
    recipient_lists.update_all(school: school)
    recipients.update_all(school: school)
    school_categories.update_all(school: school)
    user_schools.update_all(school: school)
    destroy
  end

end
