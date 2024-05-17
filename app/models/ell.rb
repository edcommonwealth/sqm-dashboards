class Ell < ApplicationRecord
  scope :by_designation, -> { all.map { |ell| [ell.designation, ell] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(ell)
    return "Not ELL" if ell.blank?

    ell = ell.delete(",")
    case ell
    in /lep\s*student\s*1st\s*year|LEP\s*student\s*not\s*1st\s*year|EL\s*Student\s*First\s*Year|LEP\s*student|^EL\s+|true|1/i
      "ELL"
    in /0|2|3|Does\s*not\s*apply/i
      "Not ELL"
    in %r{^#*N/*A$|Unknown}i
      "Unknown"
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
