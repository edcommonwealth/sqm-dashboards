class Sped < ApplicationRecord
  scope :by_designation, -> { all.map { |sped| [sped.designation, sped] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(sped)
    return "Not Special Education" if sped.blank?

    case sped
    in /active|^A$|1|^Special\s*Education$/i
      "Special Education"
    in %r{^I$|exited|0|^Not\s*Special\s*Education$|Does\s*not\s*apply|Referred|Ineligible|^No\s*special\s*needs$|Not\s*SPED|^#*N/*A$}i
      "Not Special Education"
    in /^Unknown|^SpecialEdStatus|^SPED/i
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
