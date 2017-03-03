class RecipientList < ApplicationRecord
  belongs_to :school

  validates :name, presence: true
  validates :recipient_ids, presence: true

  attr_accessor :recipient_id_array
  before_validation :convert_recipient_id_array
  after_initialize :set_recipient_id_array

  def recipients
    recipient_id_array.collect { |id| school.recipients.where(id: id).first }
  end

  private

    def convert_recipient_id_array
      return if recipient_id_array.blank?
      self.recipient_ids = recipient_id_array.reject { |id| id.to_s.empty? }.join(',')
    end

    def set_recipient_id_array
      return if recipient_ids.blank?
      self.recipient_id_array = recipient_ids.split(',').map(&:to_i)
    end

end
