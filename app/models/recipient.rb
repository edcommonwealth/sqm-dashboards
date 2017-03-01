require 'csv'

class Recipient < ApplicationRecord
  belongs_to :school
  validates_associated :school

  validates :name, presence: true

  def self.import(file)
    CSV.foreach(file.path, headers: true) do |row|
      recipient_hash = row.to_hash
      recipient = Recipient.where(phone: recipient_hash["phone"])

      if recipient.count == 1
        recipient.first.update_attributes(recipient_hash)
      else
        Recipient.create!(recipient_hash)
      end
    end
  end

end
