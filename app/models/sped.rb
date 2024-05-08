class Sped < ApplicationRecord
  scope :by_designation, -> { all.map { |sped| [sped.designation, sped] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(sped)
    return "Not Special Education" if sped.blank? || sped.nil?

    case sped
    in /active|^A$|1/i
      "Special Education"
    in /^I$|exited|0/i
      "Not Special Education"
    in /^NA$|^#NA$|Unknown/i
      "Unknown"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing Special Education column. '#{sped}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end
end
