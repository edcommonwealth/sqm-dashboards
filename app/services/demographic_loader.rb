# frozen_string_literal: true

require 'csv'

class DemographicLoader
  def self.load_data(filepath:)
    CSV.parse(File.read(filepath), headers: true) do |row|
      process_race(row:)
      process_gender(row:)
    end
  end

  def self.process_race(row:)
    qualtrics_code = row['Race Qualtrics Code'].to_i
    designation = row['Race/Ethnicity']
    return unless qualtrics_code && designation

    if qualtrics_code.between?(6, 7)
      UnknownRace.new(qualtrics_code:, designation:)
    else
      KnownRace.new(qualtrics_code:, designation:)
    end
  end

  def self.process_gender(row:)
    qualtrics_code = row['Gender Qualtrics Code'].to_i
    designation = row['Sex/Gender']
    return unless qualtrics_code && designation

    gender = Gender.find_or_create_by!(qualtrics_code:, designation:)
    gender.save
  end
end

class KnownRace
  def initialize(qualtrics_code:, designation:)
    Race.find_or_create_by!(qualtrics_code:, designation:)
  end
end

class UnknownRace
  def initialize(qualtrics_code:, designation:)
    Race.find_or_create_by!(qualtrics_code: 99, designation: 'Unknown')
  end
end
