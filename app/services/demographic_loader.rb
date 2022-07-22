# frozen_string_literal: true

require 'csv'

class DemographicLoader
  def self.load_data(filepath:)
    CSV.parse(File.read(filepath), headers: true) do |row|
      qualtrics_code = row['Race Qualtrics Code'].to_i
      designation = row['Race/Ethnicity']
      next unless qualtrics_code && designation

      if qualtrics_code.between?(6, 7)
        UnknownRace.new(qualtrics_code:, designation:)
      else
        KnownRace.new(qualtrics_code:, designation:)
      end
    end
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
