class Language < ApplicationRecord
  scope :by_designation, -> { all.map { |language| [language.designation, language] }.to_h }
  has_many :parents, dependent: :nullify

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(language)
    return "Unknown" if language.blank?

    case language
    in /^1$|^1[^0]/i
      "English"
    in /^2$/i
      "Portuguese"
    in /^3$/i
      "Spanish"
    in /^99$|^100$/i
      "Unknown"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing Language column. '#{language}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end
end
