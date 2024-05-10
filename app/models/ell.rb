class Ell < ApplicationRecord
  scope :by_designation, -> { all.map { |ell| [ell.designation, ell] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(ell)
    return "Not ELL" if ell.blank? || ell.nil?

    ell = ell.delete(",")
    case ell
    in /lep\s*student\s*1st\s*year|LEP\s*student\s*not\s*1st\s*year|EL\s*Student\s*First\s*Year|LEP\s*student|^EL|true/i
      "ELL"
    in /^NA$|^#NA$|^NA|0|Does\s*not\s*apply|Unknown/i
      "Not ELL"
    else
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing English Language Learner column.  '#{ell}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end
end
