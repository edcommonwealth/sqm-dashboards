require 'csv'

class Recipient < ApplicationRecord
  belongs_to :school
  validates_associated :school

  has_many :attempts

  validates :name, presence: true

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

end
