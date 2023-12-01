class Gender < ApplicationRecord
  scope :by_qualtrics_code, lambda {
    all.map { |gender| [gender.qualtrics_code, gender] }.to_h
  }

  def self.qualtrics_code_from(word)
    case word
    when /Female|F|1/i
      1
    when /Male|M|2/i
      2
    when /Another\s*Gender|Gender Identity not listed above|3/i
      4
    when /Non-Binary|N|4/i
      4
    when %r{^#*N/*A$}i
      nil
    else
      99
    end
  end
end
