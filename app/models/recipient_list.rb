class RecipientList < ApplicationRecord
  belongs_to :school
  has_many :schedules

  validates_associated :school
  validates :name, presence: true

  attr_accessor :recipient_id_array
  before_validation :convert_recipient_id_array
  after_initialize :set_recipient_id_array

  after_save :sync_recipient_schedules

  def recipients
    recipient_id_array.collect { |id| school.recipients.where(id: id).first }
  end

  private

    def convert_recipient_id_array
      return if recipient_id_array.blank? || (recipient_ids_was != recipient_ids)
      self.recipient_ids = recipient_id_array.reject { |id| id.to_s.empty? }.join(',')
    end

    def set_recipient_id_array
      return if recipient_id_array.present?
      self.recipient_id_array = (recipient_ids || '').split(',').map(&:to_i)
    end

    def sync_recipient_schedules
      return unless recipient_ids_was.present? && recipient_ids_was != recipient_ids
      old_ids = recipient_ids_was.split(/,/)
      new_ids = recipient_ids.split(/,/)
      (old_ids - new_ids).each do |deleted_recipient|
        schedules.each do |schedule|
          schedule.recipient_schedules.for_recipient(deleted_recipient).first.destroy
        end
      end

      (new_ids - old_ids).each do |new_recipient|
        schedules.each do |schedule|
          RecipientSchedule.create_for_recipient(new_recipient, schedule)
        end
      end
    end

end
