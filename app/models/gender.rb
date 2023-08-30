class Gender < ApplicationRecord
  scope :by_qualtrics_code, lambda {
    all.map { |gender| [gender.qualtrics_code, gender] }.to_h
  }
end
