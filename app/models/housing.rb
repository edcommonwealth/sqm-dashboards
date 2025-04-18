class Housing < ApplicationRecord
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
