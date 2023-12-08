class Race < ApplicationRecord
  include FriendlyId
  has_many :student_races
  has_many :students, through: :student_races
  friendly_id :designation, use: [:slugged]

  scope :by_qualtrics_code, lambda {
    all.map { |race| [race.qualtrics_code, race] }.to_h
  }

  # TODO: look for alaska native
  # Todo: split up possibilities by first a comma and then the word and
  def self.qualtrics_code_from(word)
    case word
    when /Native\s*American|American\s*Indian|Alaskan\s*Native|1/i
      1
    when /\bAsian|Pacific\s*Island|Hawaiian|2/i
      2
    when /Black|African\s*American|3/i
      3
    when /Hispanic|Latinx|4/i
      4
    when /White|Caucasian|5/i
      5
    when /Prefer not to disclose|6/i
      6
    when /Prefer to self-describe|7/i
      7
    when /Middle\s*Eastern|North\s*African|8/i
      8
    when %r{^#*N/*A$}i
      nil
    else
      99
    end
  end
end
