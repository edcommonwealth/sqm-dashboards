class Gender < ApplicationRecord
  scope :gender_hash, lambda {
    all.map { |gender| [gender.qualtrics_code, gender] }.to_h
  }
end
