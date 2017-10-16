require 'csv'

class Recipient < ApplicationRecord
  belongs_to :school
  validates_associated :school

  has_many :recipient_schedules
  has_many :attempts

  has_many :students

  validates :name, presence: true

  scope :for_school, -> (school) { where(school: school) }

  before_destroy :sync_lists

  def self.import(school, file)
    CSV.foreach(file.path, headers: true) do |row|
      school.recipients.create!(row.to_hash)
      # recipient_hash = row.to_hash
      # recipient = school.recipients.where(phone: recipient_hash["phone"])
      #
      # if recipient.count == 1
      #   recipient.first.update_attributes(recipient_hash)
      # else
      #   school.recipients.create!(recipient_hash)
      # end
    end
  end

  def update_counts
    update_attributes(
      attempts_count: attempts.count,
      responses_count: attempts.with_answer.count
    )
  end

  private

    def sync_lists
      school.recipient_lists.each do |recipient_list|
        next if recipient_list.recipient_id_array.index(id).nil?
        updated_ids = recipient_list.recipient_id_array - [id]
        recipient_list.update_attributes(recipient_id_array: updated_ids)
      end
    end

end
