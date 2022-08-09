# frozen_string_literal: true

class RaceScoreCalculator
  include Analyze::Graph::Column::RacialScore
  attr_reader :measure, :school, :academic_year, :race

  def initialize(measure:, school:, academic_year:, race:)
    @measure = measure
    @school = school
    @academic_year = academic_year
    @race = race
  end

  def score
    race_score(measure:, school:, academic_year:, race:)
  end
end
