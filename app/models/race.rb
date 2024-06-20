class Race < ApplicationRecord
  include FriendlyId
  has_many :student_races
  has_many :students, through: :student_races
  friendly_id :designation, use: [:slugged]

  scope :by_qualtrics_code, lambda {
    all.map { |race| [race.qualtrics_code, race] }.to_h
  }

  def self.qualtrics_code_from(word)
    return nil if word.blank?

    case word
    when /Native\s*American|American\s*Indian|Alaskan\s*Native|1/i
      1
    when /\bAsian|Pacific\s*Island|Hawaiian|2/i
      2
    when /Black|African\s*American|3/i
      3
    when /Hispanic|Latinx|4/i
      4
    when /White|Caucasian|Caucasion|5/i
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
      puts "************************************"
      puts "********      ERROR       **********"
      puts ""
      puts "Error parsing race column.  '#{word}' is not a known value. Halting execution"
      puts ""
      puts "************************************"
      exit
    end
  end

  def self.normalize_race_list(codes)
    # if anyone selects not to disclose their race or prefers to self-describe, categorize that as unknown race
    races = codes.map do |code|
      code = 99 if [6, 7].include?(code) || code.nil? || code.zero?
      code
    end.uniq

    races.delete(99) if races.length > 1 # remove unkown race if other races present
    races << 100 if races.length > 1 # add multiracial designation if multiple races present
    races << 99 if races.length == 0 # add unknown race if other races missing
    races
  end
end

