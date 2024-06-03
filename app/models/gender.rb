class Gender < ApplicationRecord
  include FriendlyId
  friendly_id :designation, use: [:slugged]

  scope :by_qualtrics_code, lambda {
    all.map { |gender| [gender.qualtrics_code, gender] }.to_h
  }

  def self.qualtrics_code_from(word)
    return 99 if word.blank?

    case word
    when /Female|^F$|1/i
      1
    when /Male|^M$|2/i
      2
    when /Another\s*Gender|Gender Identity not listed above|3|7/i
      4 # We categorize any self reported gender as non-binary
    when /Non-Binary|^N$|4/i
      4
    when /Prefer not to disclose|6/i
      99
    when %r{^#*N/*A$}i
      99
    else
      99
    end
  end
end
