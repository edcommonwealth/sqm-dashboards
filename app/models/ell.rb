class Ell < ApplicationRecord
  scope :by_designation, -> { all.map { |ell| [ell.designation, ell] }.to_h }

  include FriendlyId

  friendly_id :designation, use: [:slugged]
  def self.to_designation(ell)
    case ell
    in /lep student 1st year|LEP student not 1st year|EL Student First Year|LEP\s*student/i
      "ELL"
    in /Does not apply/i
      "Not ELL"
    else
      "Unknown"
    end
  end
end
