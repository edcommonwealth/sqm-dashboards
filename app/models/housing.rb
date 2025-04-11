class Housing < ApplicationRecord
  has_many :parents, dependent: :nullify
  scope :by_designation, -> { all.map { |housing| [housing.designation, housing] }.to_h }

  def self.to_designation(housing)
    return "Unknown" if housing.blank?

    housing = housing
    case housing
    in /^1$/i
      "Own"
    in /^2$/i
      "Rent"
    in /^99$|^100$/i
      "Unknown"
    else
      "Unknown"
    end
  end
end
