# frozen_string_literal: true

class DemographicLoader
  def self.load_data(filepath:)
    CSV.parse(File.read(filepath), headers: true) do |row|
      process_race(row:)
      process_gender(row:)
      create_from_column(column: "Income", row:, model: Income)
      create_from_column(column: "ELL", row:, model: Ell)
      create_from_column(column: "Special Ed Status", row:, model: Sped)
      create_from_column(column: "Housing", row:, model: Housing)
      create_from_column(column: "Language", row:, model: Language)
      create_from_column(column: "Employment", row:, model: Employment)
      create_from_column(column: "Education", row:, model: Education)
      create_from_column(column: "Benefits", row:, model: Benefit)
    end
  end

  def self.process_race(row:)
    qualtrics_code = row["Race Qualtrics Code"].to_i
    designation = row["Race/Ethnicity"]
    return unless qualtrics_code && designation

    if qualtrics_code.between?(6, 7)
      UnknownRace.new(qualtrics_code:, designation:)
    else
      KnownRace.new(qualtrics_code:, designation:)
    end
  end

  def self.process_gender(row:)
    qualtrics_code = row["Gender Qualtrics Code"].to_i
    designation = row["Sex/Gender"]
    return unless qualtrics_code && designation

    gender = ::Gender.find_or_create_by!(qualtrics_code:, designation:)
    gender.save
  end

  def self.create_from_column(column:, row:, model:)
    designation = row[column]
    return unless designation

    model.find_or_create_by!(designation:)
  end
end

class KnownRace
  def initialize(qualtrics_code:, designation:)
    known = Race.find_or_create_by!(qualtrics_code:)
    known.designation = designation
    known.slug = designation.parameterize
    known.save
  end
end

class UnknownRace
  def initialize(qualtrics_code:, designation:)
    unknown = Race.find_or_create_by!(qualtrics_code: 99)
    unknown.designation = "Race/Ethnicity Not Listed"
    unknown.slug = designation.parameterize
    unknown.save
  end
end
