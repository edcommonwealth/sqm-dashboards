class DashboardController < ApplicationController
  before_action :set_school

  def index
    authenticate(district.name.downcase, "#{district.name.downcase}!")
    @construct_graph_row_presenters = [
      ConstructGraphRowPresenter.new(construct: Construct.find_by_construct_id('1A-i'), score: score('1A-i'))
    ]
  end

  private

  def set_school
    @school = School.find_by_slug school_slug
  end

  def school_slug
    params[:school_id]
  end

  def district
    @district ||= @school.district
  end

  def score(construct_id)
    # for this school, get the score for this construct
    # what we mean by this is:
    # for the given school, find the responses to the survey of the given academic year (AY)
    # that respond to questions that belong the given construct,
    # then average the scores for those responses
    # E.g. Find the responses from AY2020-21 from Milford High School, then get just those
    # responses that correspond to questions from Professional Qualifications
    # and then average the scores from those responses
    # all_responses_from_milford_in_2020-21 = SurveyResponse.where('academic_year = 2020-21').where('school = Milford High School')
    # milford-2020-21-responses-to-1A-i = all_responses_from_milford_2020-21.filter { |response| response.question.construct.construct_id = '1A-i' }
    # score = average(milford-2020-21-responses-to-1A-i)
    4.8
  end

end

#
# response belongs_to question
# question belongs_to construct
# response.question.construct